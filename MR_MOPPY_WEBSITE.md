# Mr. Moppy website draft

Standalone responsive static site. Open website/index.html locally to review; no build or dependencies required.

## Cloudflare Pages

Connect this GitHub repository to Cloudflare Pages. Select production branch `website/mr-moppy-draft`, framework None, root directory `website`, build command `exit 0`, build output directory `.`. No environment variables are required. This produces a pages.dev preview without changing GoDaddy DNS. Cloudflare connection/deployment is not completed by this commit.

Later, move the website folder into a dedicated mr-moppy repository if desired. Add mr-moppy.com through Cloudflare Pages custom domains before making the corresponding GoDaddy DNS changes. Determine apex-domain requirements at that stage; leave current DNS untouched now.

## Draft content and launch checklist

Business name and domain provided by owner. Connected operational records suggest home, holiday-property, and workspace cleaning in the Algarve. Exact services and coverage require owner confirmation. No client, staff, financial, or private operational records are included in the site.

Before public launch: confirm branding, services, coverage, public business contact details, legal business details, and privacy information; replace the preview notice and FAQ draft language; connect a real enquiry destination; remove noindex and the robots.txt disallow. Do not represent the enquiry builder as a sent request: it only prepares text locally, sends no data, stores no data, and confirms no booking. No invented pricing, reviews, certifications, or contact details.

## Review

Check desktop and mobile layouts, keyboard navigation, service selection links, required fields, enquiry generation, clipboard success and manual-copy fallback. JavaScript syntax, local assets, internal anchors, service selection, enquiry formatting, whitespace rejection, clipboard success, and manual-copy fallback were checked using an in-memory JavaScript harness. Real browser rendering and native browser form validation remain unverified because no browser or shell execution tool is available in the authoring session.

Official setup references:
- https://developers.cloudflare.com/pages/framework-guides/deploy-anything/
- https://developers.cloudflare.com/pages/configuration/git-integration/github-integration/

The custom 404.html ensures unknown paths return a not-found page instead of the default single-page-app fallback.

Set Pages preview branch deployments to None initially: other repository branches do not contain this website. Optional build watch include: website/*.
