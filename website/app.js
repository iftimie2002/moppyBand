'use strict';
document.getElementById('year').textContent = new Date().getFullYear();
const form = document.getElementById('enquiry-form');
form.querySelector('[type="submit"]').disabled = false;
document.querySelectorAll('[data-service]').forEach(link => link.addEventListener('click', () => { form.elements.service.value = link.dataset.service; }));
form.addEventListener('submit', event => {
  event.preventDefault();
  const location = form.elements.location;
  const details = form.elements.details;
  for (const field of [location, details]) {
    if (!field.value.trim()) {
      document.getElementById('status').textContent = 'Please add your location and a few details about the clean.';
      field.focus();
      return;
    }
  }
  const data = new FormData(form);
  document.getElementById('enquiry-text').value = ['Mr. Moppy cleaning enquiry', 'Service: ' + data.get('service'), 'Location: ' + data.get('location').trim(), '', data.get('details').trim()].join('\n');
  document.getElementById('result').hidden = false;
  document.getElementById('status').textContent = 'Your enquiry is ready to copy. It has not been sent.';
});
document.getElementById('copy').addEventListener('click', async () => {
  const field = document.getElementById('enquiry-text');
  try {
    await navigator.clipboard.writeText(field.value);
    document.getElementById('status').textContent = 'Copied. Your enquiry has not been sent.';
  } catch {
    field.focus(); field.select();
    document.getElementById('status').textContent = 'Select and copy the enquiry text manually. It has not been sent.';
  }
});