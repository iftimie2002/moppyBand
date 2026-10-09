import test from 'node:test';
import assert from 'node:assert/strict';
import { ensureProject, projectName, productionBranch } from './provision-pages.mjs';

const credentials = { accountId: 'a'.repeat(32), token: 'test-only-token' };
const project = { name: projectName, production_branch: productionBranch, subdomain: projectName + '.pages.dev' };
const response = (status, data) => ({ status, ok: status >= 200 && status < 300, json: async () => data });

test('reuses the matching project without creating another', async () => {
  let calls = 0;
  const result = await ensureProject({ ...credentials, request: async (url, options) => {
    calls++;
    assert.ok(url.endsWith('/' + projectName));
    assert.equal(options.method, undefined);
    return response(200, { success: true, result: project });
  } });
  assert.equal(result.subdomain, project.subdomain);
  assert.equal(calls, 1);
});

test('creates the project only after a 404', async () => {
  const calls = [];
  await ensureProject({ ...credentials, request: async (url, options) => {
    calls.push(options);
    return calls.length === 1 ? response(404, {}) : response(200, { success: true, result: project });
  } });
  assert.equal(calls[1].method, 'POST');
  assert.deepEqual(JSON.parse(calls[1].body), { name: projectName, production_branch: productionBranch });
});

test('authentication failures do not create a project', async () => {
  for (const status of [401, 403, 500]) {
    let calls = 0;
    await assert.rejects(ensureProject({ ...credentials, request: async () => {
      calls++;
      return response(status, {});
    } }), /setup failed/);
    assert.equal(calls, 1);
  }
});

test('missing credentials make no network call', async () => {
  await assert.rejects(ensureProject({ accountId: '', token: '', request: () => {
    assert.fail('Network call with missing credentials');
  } }), /GitHub Actions secrets/);
});

test('an existing project with different settings is not adopted', async () => {
  for (const changed of [{ production_branch: 'main' }, { source: { type: 'github' } }]) {
    await assert.rejects(ensureProject({ ...credentials, request: async () =>
      response(200, { success: true, result: { ...project, ...changed } })
    }), /different configuration/);
  }
});

test('rejects Cloudflare errors and unexpected hostnames', async () => {
  await assert.rejects(ensureProject({ ...credentials, request: async () =>
    response(200, { success: false })
  }), /did not confirm/);
  await assert.rejects(ensureProject({ ...credentials, request: async () =>
    response(200, { success: true, result: { ...project, subdomain: 'example.com' } })
  }), /valid Pages hostname/);
});
