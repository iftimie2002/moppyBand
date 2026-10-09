import { appendFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export const projectName = 'mr-moppy-iftimie2002-preview';
export const productionBranch = 'website/mr-moppy-draft';

export async function ensureProject({ accountId, token, request = fetch }) {
  if (!/^[a-f0-9]{32}$/i.test(accountId || '') || !token) {
    throw new Error('Add a valid CLOUDFLARE_ACCOUNT_ID and CLOUDFLARE_API_TOKEN to GitHub Actions secrets.');
  }
  const base = 'https://api.cloudflare.com/client/v4/accounts/' + accountId + '/pages/projects';
  const headers = { Authorization: 'Bearer ' + token, 'Content-Type': 'application/json' };
  let response = await request(base + '/' + projectName, { headers, signal: AbortSignal.timeout(30000) });
  if (response.status === 404) {
    response = await request(base, {
      method: 'POST',
      headers,
      body: JSON.stringify({ name: projectName, production_branch: productionBranch }),
      signal: AbortSignal.timeout(30000)
    });
  }
  if (!response.ok) {
    throw new Error('Cloudflare project setup failed (HTTP ' + response.status + '). Check the account ID and Pages Edit token permission.');
  }
  const data = await response.json();
  const project = data.result;
  if (!data.success || !project) throw new Error('Cloudflare did not confirm project setup.');
  if (project.name !== projectName || project.production_branch !== productionBranch || project.source) {
    throw new Error('An existing Cloudflare project has a different configuration. Deployment stopped for review.');
  }
  if (typeof project.subdomain !== 'string' || !/^[a-z0-9-]+\.pages\.dev$/.test(project.subdomain)) {
    throw new Error('Cloudflare did not return a valid Pages hostname.');
  }
  return project;
}

if (process.argv[1] && fileURLToPath(import.meta.url) === resolve(process.argv[1])) {
  try {
    const project = await ensureProject({
      accountId: process.env.CLOUDFLARE_ACCOUNT_ID,
      token: process.env.CLOUDFLARE_API_TOKEN
    });
    appendFileSync(process.env.GITHUB_OUTPUT, 'site_url=https://' + project.subdomain + '\n');
    console.log('Cloudflare Pages project is ready: ' + project.subdomain);
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
