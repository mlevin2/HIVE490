# HIVE 490 — Beemail

Source for the HIVE 490 beekeeping blog: a plain [Jekyll](https://jekyllrb.com/)
site, hosted free on GitHub Pages at a custom domain. No database, no server,
no build service to pay for or maintain — push markdown, GitHub builds and
deploys it.

## Stack

- **Jekyll**, static site generator, built into GitHub Pages
- **GitHub Pages**, hosting + free HTTPS, custom domain support
- **Mailchimp** (free tier), newsletter delivery via RSS-to-email — see
  [Mailchimp setup](#mailchimp-setup) below
- No comments anywhere, by design. If people want to respond, they can
  reply to the Beemail email.

## Local preview

Requires Ruby and [Bundler](https://bundler.io/) (`gem install bundler` if
you don't have it). A Ruby version manager (rbenv, chruby, asdf, or
Homebrew's `ruby` formula) is recommended — the macOS system Ruby is too old
for modern Jekyll.

```
make install   # one-time (and after editing the Gemfile)
make serve     # preview at http://localhost:4000, rebuilds on save
```

`make build` builds the static site into `_site/` without serving it —
useful for sanity-checking output, but you don't need to run it day to day,
and you never commit `_site/` (it's gitignored; GitHub builds it fresh on
every push).

## Writing and publishing a post

1. Add a file to `_posts/` named `YYYY-MM-DD-slug.md`, e.g.
   `_posts/2026-11-02-fall-inspection.md`.
2. Front matter:

   ```yaml
   ---
   title: "Fall Inspection"
   description: "One sentence summarizing this update — used for SEO and link previews."
   ---
   ```

3. Write the body in Markdown below the front matter. Before adding a
   photo to `assets/images/`, run it through `make optimize-image` to
   resize it down and strip metadata (including GPS location) — phone
   photos are often several MB and don't need to be that large on the
   web:

   ```
   make optimize-image SRC=~/Desktop/photo.jpg DEST=assets/images/2026-11-02-example.jpg
   ```

   Then reference it with standard Markdown
   (`![alt text](/assets/images/whatever.jpg)`) — always include real alt
   text, both for accessibility and because it feeds SEO.
4. Preview with `make serve`, then commit and push to `main`:

   ```
   git add _posts/2026-11-02-fall-inspection.md assets/images/...
   git commit -m "Beemail: fall inspection"
   git push
   ```

5. GitHub Pages rebuilds and deploys automatically (usually under a
   minute). No manual build step, no FTP, nothing else to do for the
   website side.

That push is also everything you need to do to trigger the email send —
see below.

## Repo setup / first deploy

Not yet done for this repo. Once you're ready:

```
gh repo create mlevin2/HIVE490 --public --source=. --remote=origin --push
```

Then on GitHub: **Settings → Pages → Build and deployment → Source:
Deploy from a branch**, branch `main`, folder `/ (root)`.

### Custom domain (hive490.buzz)

The `CNAME` file in this repo already points Pages at `hive490.buzz`. You
still need to point the domain's DNS at GitHub:

- **Apex domain (`hive490.buzz`)** — four `A` records pointing at GitHub
  Pages' IPs:
  ```
  185.199.108.153
  185.199.109.153
  185.199.110.153
  185.199.111.153
  ```
- **`www` subdomain** (optional, if you want `www.hive490.buzz` to also
  work) — a `CNAME` record pointing to `mlevin2.github.io`.

Set these with whoever you registered `hive490.buzz` through. After DNS
propagates (can take a few hours), go to **Settings → Pages** on GitHub and
check **Enforce HTTPS** once it becomes available — GitHub provisions a
free certificate automatically.

## SEO

Already set up, nothing further required per-post beyond filling in
`description` in front matter:

- `jekyll-seo-tag` — page titles, meta descriptions, canonical URLs, Open
  Graph + Twitter Card tags, and JSON-LD structured data on every page
- `jekyll-sitemap` — auto-generated `sitemap.xml`, referenced from
  `robots.txt`
- `jekyll-feed` — `feed.xml` (also what Mailchimp reads from, see below)
- A default social-share image (`assets/images/social-share.png`) is used
  for link previews on any post that doesn't set its own `image:`
- Clean, stable permalinks (`/2026/11/fall-inspection/`)
- Full favicon set (SVG + ICO + PNG sizes + web manifest) so the site
  looks correct in every browser tab, bookmark, and Android home-screen
  shortcut

## Mailchimp setup

The goal: write a post once, and it goes out both as a web page and as an
email, without copy-pasting content into a second tool. Mailchimp's
**RSS-to-email** campaigns do this — they poll `feed.xml` and send an
email automatically whenever a new post appears in it.

### One-time setup

1. **Create a Mailchimp account** (free tier). At under 50 subscribers and
   at most one send a month, you're nowhere near the free plan's contact
   or send limits.
2. **Create an Audience** (Mailchimp's term for a mailing list).
3. **Create a signup form**: Audience → Signup forms → either the
   Mailchimp-hosted form or an embedded form on another page. Copy its
   URL.
4. Put that URL in `_config.yml`:
   ```yaml
   mailchimp_signup_url: "https://your-actual-signup-form-url"
   ```
   This single config value drives every "Subscribe" link/button across
   the site (header, footer, homepage banner, bottom of every post).
5. **Create an RSS-Driven Campaign**: Campaigns → Create → look for "RSS"
   as the trigger/automation type (Mailchimp's UI has moved this around
   over the years — if you don't see it under Campaigns, check
   Automations → Classic Automations, or search "RSS" in Mailchimp's help
   search from within your account).
   - RSS feed URL: `https://hive490.buzz/feed.xml`
   - Send frequency: "As new items are published" — at most-monthly
     posting, the polling delay (Mailchimp checks the feed roughly hourly
     to daily on the free tier) is a total non-issue.
   - In the RSS content block, choose **full content**, not the
     truncated/excerpt option (Mailchimp defaults to truncated). The feed
     already carries each post's full content — `jekyll-feed` doesn't
     excerpt it — so this just controls what Mailchimp actually displays
     in the email.
   - Design the email template once — pull in the site's colors (`#59AD40`
     green, `#FFC72C` gold, `#FFF8E6` cream background) and set the font to
     something close to Jost if Mailchimp's font picker has it, otherwise
     a similar geometric sans. You only do this once; it applies to every
     future post automatically.
   - Send yourself a test before turning it on for real.
6. Turn the RSS campaign on.

### Ongoing workflow (after setup)

1. Write the post in `_posts/`, as described above.
2. `git push`.
3. That's it. GitHub Pages publishes the page; Mailchimp picks up the new
   `feed.xml` entry on its next poll and emails your Audience
   automatically, using the template you built once.

If you'd rather have full manual control over the email's exact wording
(RSS campaigns auto-generate the email layout from your post content,
which is usually fine but not infinitely flexible), the fallback is: write
the post, push it, then manually create a regular Mailchimp campaign and
paste the content in. That's more work per post, so start with the
RSS-driven approach and only switch to manual if the auto-generated emails
don't look right.

## Project structure

```
_config.yml       Site settings — title, URL, Mailchimp signup link, plugins
_layouts/         default.html (shell), home.html (post list), post.html
_includes/        head.html (SEO/meta/favicons), header.html, footer.html
_posts/           Beemail entries, one file per post
assets/css/       Hand-written CSS (no framework, no Sass pipeline)
assets/images/    Logo, favicons, social-share image, post images
index.md          Homepage (uses home.html layout)
about.md          About page
CNAME             Custom domain for GitHub Pages
robots.txt        Points crawlers at sitemap.xml
site.webmanifest  Android/PWA icon metadata
Makefile          make install / serve / build / clean
```
