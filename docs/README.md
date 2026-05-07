# Medity site (GitHub Pages)

This `docs/` folder is the source for [aituglo.github.io/medity](https://aituglo.github.io/medity).
It hosts the privacy policy and acknowledgements page that the App Store
listing and the in-app `Settings → Privacy / Acknowledgements` rows link
to.

## Setup (one time)

1. On GitHub, push the repo (`git push origin main`).
2. Repo → **Settings → Pages**.
3. Under **Source**, choose **Deploy from a branch**.
4. Branch: `main`, folder: `/docs`.
5. Save. After a minute the site is live at
   `https://aituglo.github.io/medity/`.

## Pages

- `/` — `index.md`, landing
- `/privacy` — privacy policy (linked from in-app Settings + App Store listing)
- `/acknowledgements` — third-party credits

## Editing

Markdown only — Jekyll renders it via the `minima` theme on GitHub's
side. No build step locally; commits to `main` trigger redeployment.
