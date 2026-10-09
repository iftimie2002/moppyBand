# Mr. Moppy website draft

Standalone responsive static site in `website/`. Open `website/index.html` locally to review. No website build or dependencies are required.

## Automated Cloudflare publishing

GitHub Actions workflow: `.github/workflows/deploy-mr-moppy.yml`.

The workflow runs on website changes pushed to `website/mr-moppy-draft`. It checks the provisioning logic, creates a matching Cloudflare Pages Direct Upload project if needed, and publishes only `website/`. Missing credentials cause publishing to be skipped with a clear workflow summary.

### One-time account connection

1. In Cloudflare, create an API token with **Account → Cloudflare Pages → Edit**, scoped to your intended account: https://dash.cloudflare.com/profile/api-tokens
2. In GitHub repository Actions secrets, add:
   - `CLOUDFLARE_API_TOKEN`: that token
   - `CLOUDFLARE_ACCOUNT_ID`: the account ID shown in your Cloudflare dashboard
3. Rerun the deployment job, or push a website change to the draft branch.

Repository secrets: https://github.com/iftimie2002/moppyBand/settings/secrets/actions

The project name is `mr-moppy-iftimie2002-preview`, with production branch `website/mr-moppy-draft`. The workflow reads the actual hostname from Cloudflare and records it in the job summary. It stops if an existing project with that name has different settings. It does not change domain or DNS settings.

This uses GitHub Actions to deploy to Cloudflare Pages. Direct Upload projects cannot later be converted to Cloudflare's native Git integration; that would require a separate Pages project. GitHub Actions provides automatic publishing already.

Official guide: https://developers.cloudflare.com/pages/how-to/use-direct-upload-with-continuous-integration/

## Domain connection later

Add `mr-moppy.com` through Cloudflare Pages custom domains before making DNS changes. Determine apex-domain requirements at that stage. Domain registration can remain with GoDaddy.

## Draft content

Business name and domain were provided by the owner. The service categories and Algarve positioning are provisional and require owner confirmation. No client, staff, financial, or private operational records are included in this repository.

Before launch: confirm branding, services, exact coverage, public contact and legal business details, and privacy information. Replace preview notices, connect a real enquiry destination, and remove noindex and the robots.txt disallow. The enquiry builder only prepares text locally; it sends and stores no data and confirms no booking. No pricing, reviews, or certifications have been invented.

## Validation

JavaScript syntax, local assets, internal anchors, service preselection, enquiry formatting, whitespace rejection, clipboard success, and manual-copy fallback passed an in-memory JavaScript harness. Six provisioning tests cover existing-project reuse, project creation after a 404, authentication failures, missing credentials, conflicting projects, and invalid API responses. The provisioning tests also run with Node's test runner in GitHub Actions.

Real-browser rendering and native browser form validation remain unverified because no browser or shell tool is available in the authoring session. Cloudflare deployment remains pending until credentials are connected.
