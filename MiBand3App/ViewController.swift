import UIKit
import CoreBluetooth
import CommonCrypto

final class ViewController: UIViewController {
    private var centralManager: CBCentralManager?
    private var miBandPeripheral: CBPeripheral?

    private var authCharacteristic: CBCharacteristic?
    private var heartRateMeasurementCharacteristic: CBCharacteristic?
    private var heartRateControlCharacteristic: CBCharacteristic?

    private let authCharacteristicUUID = CBUUID(string: "00000009-0000-3512-2118-0009af100700")
    private let heartRateMeasurementUUID = CBUUID(string: "00002a37-0000-1000-8000-00805f9b34fb")
    private let heartRateControlUUID = CBUUID(string: "00002a39-0000-1000-8000-00805f9b34fb")

    private let authKey = Data([0xc7, 0x8f, 0xf2, 0xf4, 0xdb, 0xc3, 0x4e, 0xaf,
                               0xa9, 0x47, 0x0e, 0x23, 0xae, 0x33, 0xa2, 0x3a])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    private func log(_ message: String) {
        print("[MiBand3] \(message)")
    }

    private func startScanning() {
        log("Starting BLE scan")
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    private func authenticate() {
        guard let peripheral = miBandPeripheral, let authCharacteristic else { return }
        log("Initiating authentication")
        peripheral.setNotifyValue(true, for: authCharacteristic)
        let requestRandom = Data([0x01, 0x00])
        peripheral.writeValue(requestRandom, for: authCharacteristic, type: .withResponse)
    }

    private func startHeartRateMonitoring() {
        guard let peripheral = miBandPeripheral,
              let heartRateMeasurementCharacteristic,
              let heartRateControlCharacteristic else { return }
        log("Subscribing to heart rate notifications")
        peripheral.setNotifyValue(true, for: heartRateMeasurementCharacteristic)
        let startMeasurement = Data([0x15, 0x01, 0x01])
        log("Sending heart rate start command")
        peripheral.writeValue(startMeasurement, for: heartRateControlCharacteristic, type: .withResponse)
    }

    private func handleAuthResponse(_ data: Data) {
        guard data.count >= 3 else {
            log("Auth response too short: \(data as NSData)")
            return
        }
        if data[0] == 0x10 && data[1] == 0x01 && data[2] == 0x01 {
            log("Auth step 1 acknowledged, awaiting random")
            return
        }
        if data[0] == 0x10 && data[1] == 0x02 {
            guard data.count >= 18 else {
                log("Random payload size invalid")
                return
            }
            let random = data.subdata(in: 2..<18)
            log("Received random challenge, encrypting")
            guard let encrypted = aesEncrypt(random, key: authKey) else {
                log("Failed to encrypt authentication challenge")
                return
            }
            var payload = Data([0x03, 0x00])
            payload.append(encrypted)
            miBandPeripheral?.writeValue(payload, for: authCharacteristic!, type: .withResponse)
            return
        }
        if data[0] == 0x10 && data[1] == 0x03 && data[2] == 0x01 {
            log("Authentication successful")
            startHeartRateMonitoring()
            return
        }
        log("Authentication failed or unknown response: \(data as NSData)")
    }

    private func aesEncrypt(_ data: Data, key: Data) -> Data? {
        guard key.count == kCCKeySizeAES128 else { return nil }
        let dataLength = data.count
        var outLength = Int(0)
        var outData = Data(count: dataLength + kCCBlockSizeAES128)

        let result = outData.withUnsafeMutableBytes { outBytes in
            data.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionECBMode),
                        keyBytes.baseAddress,
                        kCCKeySizeAES128,
                        nil,
                        dataBytes.baseAddress,
                        dataLength,
                        outBytes.baseAddress,
                        outData.count,
                        &outLength
                    )
                }
            }
        }

        guard result == kCCSuccess else { return nil }
        outData.removeSubrange(outLength..<outData.count)
        return outData
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            log("Bluetooth powered on")
            startScanning()
        case .poweredOff:
            log("Bluetooth powered off")
        case .unauthorized:
            log("Bluetooth unauthorized")
        case .unsupported:
            log("Bluetooth unsupported")
        case .resetting:
            log("Bluetooth resetting")
        case .unknown:
            log("Bluetooth state unknown")
        @unknown default:
            log("Bluetooth state unknown (default)")
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name ?? "Unknown"
        log("Discovered peripheral: \(name) (RSSI: \(RSSI))")
        if name.contains("Mi Band 3") {
            log("Mi Band 3 found, connecting")
            central.stopScan()
            miBandPeripheral = peripheral
            peripheral.delegate = self
            central.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        log("Connected to \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices(nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        log("Failed to connect: \(error?.localizedDescription ?? "unknown error")")
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        log("Disconnected: \(error?.localizedDescription ?? "no error")")
        startScanning()
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            log("Service discovery error: \(error.localizedDescription)")
            return
        }
        peripheral.services?.forEach { service in
            log("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error {
            log("Characteristic discovery error: \(error.localizedDescription)")
            return
        }
        service.characteristics?.forEach { characteristic in
            log("Characteristic: \(characteristic.uuid) properties: \(characteristic.properties)")
            switch characteristic.uuid {
            case authCharacteristicUUID:
                authCharacteristic = characteristic
                authenticate()
            case heartRateMeasurementUUID:
                heartRateMeasurementCharacteristic = characteristic
            case heartRateControlUUID:
                heartRateControlCharacteristic = characteristic
            default:
                break
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            log("Notification state error for \(characteristic.uuid): \(error.localizedDescription)")
        } else {
            log("Notification state updated for \(characteristic.uuid): \(characteristic.isNotifying)")
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            log("Update value error for \(characteristic.uuid): \(error.localizedDescription)")
            return
        }
        guard let data = characteristic.value else { return }
        if characteristic.uuid == authCharacteristicUUID {
            handleAuthResponse(data)
            return
        }
        if characteristic.uuid == heartRateMeasurementUUID {
            parseHeartRate(data)
        }
    }

    private func parseHeartRate(_ data: Data) {
        guard data.count >= 2 else { return }
        let flags = data[0]
        if flags & 0x01 == 0 {
            let hr = Int(data[1])
            log("Heart Rate: \(hr) bpm")
        } else if data.count >= 3 {
            let hr = Int(data[1]) | (Int(data[2]) << 8)
            log("Heart Rate: \(hr) bpm")
        }
    }
}
