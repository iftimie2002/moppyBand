# Mr. Moppy website

A responsive static website for Mr. Moppy, prepared for Cloudflare Pages Git integration. Website files are in `website/`; no build dependencies are required.

## Connect in Cloudflare Workers & Pages

Choose **Create application → Pages → Connect to Git**, connect GitHub, and select the repository containing this website.

| Setting | Value |
| --- | --- |
| Framework preset | None |
| Root directory | `website` |
| Build command | `exit 0` |
| Build output directory | `.` |
| Environment variables | None |

For the prepared draft currently in `iftimie2002/moppyBand`, select production branch `website/mr-moppy-draft`. For a dedicated `mr-moppy` repository, use the branch containing the website (normally `main`).

Cloudflare handles deployments when you push to the selected branch. No API tokens or GitHub Actions secrets are needed for this native Git integration. Use the generated `pages.dev` address initially; connect `mr-moppy.com` later. If connecting the current draft repository, set preview branch deployments to None because other branches do not contain the website.

Official guides:
- https://developers.cloudflare.com/pages/get-started/git-integration/
- https://developers.cloudflare.com/pages/framework-guides/deploy-anything/

## Preview locally

Open `website/index.html` in a browser. The enquiry builder operates locally and provides a manual-copy fallback when clipboard access is unavailable.

## Content status

Business name and domain were provided by the owner. Service categories and Algarve positioning are provisional and require owner confirmation. No client, staff, financial, or private operational records are included in the website.

Before public launch, confirm branding, services, exact coverage, public contact details, legal business details, and privacy information. Replace preview notices, connect an enquiry destination, and remove the noindex meta tags and robots.txt disallow.

The enquiry builder prepares text only. It sends and stores no data and confirms no booking. No pricing, reviews, or certifications have been invented.

## Verification

JavaScript syntax, local assets, internal anchors, service preselection, enquiry formatting, whitespace rejection, clipboard success, and manual-copy fallback passed an in-memory JavaScript harness. Real-browser visual review and native browser form validation remain outstanding. The custom 404 page handles unknown paths in Cloudflare Pages.
