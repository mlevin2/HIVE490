# HIVE 490 — Beemail

Source for the HIVE 490 beekeeping blog: a plain [Jekyll](https://jekyllrb.com/)
site, hosted free on GitHub Pages at a custom domain. No database, no server,
no build service to pay for or maintain — push markdown, GitHub builds and
deploys it.

## Stack

- **Jekyll**, static site generator, built into GitHub Pages
- **GitHub Pages**, hosting + free HTTPS, custom domain support
- **Mailchimp** (free tier), newsletter delivery — the RSS automation
  that would normally do this automatically doesn't work on the free
  plan (it requires scheduling, which free doesn't include), so sending
  is a one-command manual step after each post; see
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

   Then reference it with standard Markdown, but use `{{ site.url }}`
   rather than a plain `/` path —
   `![alt text]({{ site.url }}/assets/images/whatever.jpg)` — always
   include real alt text, both for accessibility and because it feeds
   SEO.

   **Why `{{ site.url }}` and not just `/assets/images/...`:** a post's
   content also gets syndicated into `feed.xml`, which is what the
   Mailchimp email (and its web archive view) renders from. A root-relative
   path like `/assets/images/whatever.jpg` resolves fine on the actual
   site, but breaks anywhere else the content gets served from — email
   clients and Mailchimp's own archive pages have no idea what domain
   "/" is supposed to mean, so the image just 404s. `{{ site.url }}`
   expands to the real `https://hive490.buzz` on the actual GitHub
   build, so links and images work correctly everywhere, including in
   the email. Locally, `make serve`/`make build` merge in
   `_config_dev.yml`, which blanks `site.url` back to empty — so the
   exact same source still gives you plain, working root-relative paths
   in local preview rather than linking out to the live production site.

   Every photo is automatically clickable to enlarge in a lightbox (see
   below), so the default single-image-per-paragraph layout already
   works well without any extra markup.

   For a nicer layout with more than one photo, two optional patterns:

   - **Wrap text around a photo** — add `{: .float-right }` or
     `{: .float-left }` right after the image:
     ```
     ![Alt text]({{ site.url }}/assets/images/whatever.jpg){: .float-right }
     ```
   - **A row of photos** — wrap them in a `photo-grid` div, with a blank
     line between each image so they land in separate grid cells:
     ```
     <div class="photo-grid" markdown="1">

     ![First photo]({{ site.url }}/assets/images/one.jpg)

     ![Second photo]({{ site.url }}/assets/images/two.jpg)

     </div>
     ```

   Either way, you can give a photo its own caption (shown in the
   lightbox, separate from its alt text) with Markdown's optional title
   string: `![Alt text]({{ site.url }}/assets/images/whatever.jpg
   "Caption shown in the lightbox")`.
4. Preview with `make serve`, then commit and push to `main`:

   ```
   git add _posts/2026-11-02-fall-inspection.md assets/images/...
   git commit -m "Beemail: fall inspection"
   git push
   ```

5. GitHub Pages rebuilds and deploys automatically (usually under a
   minute). No manual build step, no FTP, nothing else to do for the
   website side.

For the email: despite the Mailchimp setup below, the RSS automation
doesn't actually send anything on the free plan — see "Sending an email
manually" further down for the process that actually works
(`make send-test` then `make send-live`, after this push).

## Repo setup / first deploy

Already done — `mlevin2/HIVE490` is live on `main`, deploying from the
branch root. Keeping the steps here as a reference in case this ever
needs to be recreated (a fork, a disaster-recovery scenario, etc.):

```
gh repo create mlevin2/HIVE490 --public --source=. --remote=origin --push
```

Then on GitHub: **Settings → Pages → Build and deployment → Source:
Deploy from a branch**, branch `main`, folder `/ (root)`.

### Custom domain (hive490.buzz)

Live and working, HTTPS enforced. The `CNAME` file in this repo points
Pages at `hive490.buzz`; DNS is set at Hover (the registrar):

- **Apex domain (`hive490.buzz`)** — four `A` records pointing at GitHub
  Pages' IPs:
  ```
  185.199.108.153
  185.199.109.153
  185.199.110.153
  185.199.111.153
  ```
- **`www` subdomain** — a `CNAME` record pointing to `mlevin2.github.io`.

**If HTTPS ever gets stuck again** (certificate not issuing even though
DNS resolves correctly — this happened once, taking ~16 hours before a
fix): clear and re-save the custom domain to force GitHub to retry
certificate provisioning from scratch, either in **Settings → Pages**
(clear the field, save, wait, type the domain back in, save) or via:
```
gh api repos/mlevin2/HIVE490/pages -X PUT -F cname=''
# wait a few seconds
gh api repos/mlevin2/HIVE490/pages -X PUT -F cname='hive490.buzz'
```
This is especially likely if the custom domain was ever saved in Pages
settings *before* DNS was fully pointed at GitHub — the first
certificate attempt fails and doesn't appear to retry on its own.

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

Already done. Steps below as a reference/runbook — e.g. if this ever
needs to be rebuilt under a different account or domain.

1. **Create a Mailchimp account** (free tier). At under 50 subscribers and
   at most one send a month, you're nowhere near the free plan's contact
   or send limits.
2. **Create an Audience** (Mailchimp's term for a mailing list).
3. **Create a signup page**: Audience → **Forms** → **Create Form** →
   **Signup landing page** (not Popup form or Embedded form — those don't
   give a standalone URL to link to). Copy its published URL.
4. Put that URL in `_config.yml`:
   ```yaml
   mailchimp_signup_url: "https://your-actual-signup-form-url"
   ```
   This single config value drives every "Subscribe" link/button across
   the site (header, footer, homepage banner, bottom of every post).
   Remember to click **Publish** on the landing page itself — saving a
   draft isn't enough to make the URL actually work.
5. **Authenticate the sending domain** (Audience → Settings → Domains →
   Authenticate): without this, Mailchimp can still send using a
   `beemail@yourdomain` From address once you've verified it (clicking a
   confirmation link), but deliverability suffers without full DKIM
   authentication. Mailchimp may be able to connect directly to some
   registrars (it did for Hover here) and add the DNS records itself; if
   not, it'll show you the CNAME records to add manually.
6. **Create the RSS automation**: Automations → look for a pre-built
   journey called **"Share blog updates via RSS"** (not under regular
   Campaigns — current Mailchimp nests this under Automations).
   - RSS feed URL: `https://hive490.buzz/feed.xml`
   - Send frequency: pick **daily** and any time of day — there's no
     literal "send immediately when published" option, but daily polling
     is indistinguishable from instant at a monthly posting cadence.
   - In the RSS content block, switch from the default **Excerpts**
     preset to **Full Posts** — this swaps in the `*|RSSITEM:CONTENT_FULL|*`
     merge tag instead of a truncated version. The feed always carries
     full content (`jekyll-feed` doesn't excerpt it); this setting
     controls what Mailchimp actually *displays*.
   - **Subject line**: use `*|RSSITEM:TITLE|*` (the individual post's
     title), not `*|RSSFEED:TITLE|*` (the site's name — same on every
     send, which defeats the point of a dynamic subject).
   - Design the email template once — pull in the site's colors (`#59AD40`
     green, `#FFC72C` gold, `#FFF8E6` cream background) and set the font to
     something close to Jost if Mailchimp's font picker has it, otherwise
     a similar geometric sans. You only do this once; it applies to every
     future post automatically.
   - Send yourself a test before turning it on for real.
7. Turn the RSS automation on (there's a "Start" button on the final
   review screen, not a "Send" button, since this is a recurring
   automation rather than a one-off campaign).

**Known limitation:** Mailchimp's landing-page signup form doesn't
render a required-field asterisk next to Email even when it's marked
required (and the other fields aren't) — this appears to be a platform
quirk on this specific form type, and the field labels aren't editable
to work around it by hand. Not worth fighting; a one-line note in the
page's intro text ("only email is required") covers it if it matters.

### The RSS automation doesn't actually work on the free plan

Found the hard way, on 2026-10-17: Mailchimp's free plan doesn't include
**email scheduling** (confirmed on their own pricing page, and via the
`send-checklist` API endpoint, which returns `"Because you're on a free
plan, you won't be able to schedule this email."`). An RSS-to-email
automation is inherently a scheduled/recurring send, so it's blocked by
this — even though the setup flow above lets you configure and fully
activate it with no warning anywhere in the UI. The automation sits
correctly configured and perpetually does nothing.

Two ways forward: upgrade to a paid plan (Essentials, their cheapest
paid tier, is $13/month at this contact count and includes scheduling —
start the 14-day free trial and re-check `send-checklist` to confirm
RSS sending actually unblocks before committing to pay), or use the
manual-send process below, which works today on the free plan for free.
The RSS automation can stay configured as-is either way — if you
upgrade later, it should just start working with nothing else to change.

### Sending an email manually (the part that actually works on free)

The trick: Mailchimp's free-plan restriction is specifically on
*scheduling* a send for later. An immediate "send now" isn't scheduling,
so it isn't blocked (confirmed empirically — a real test send through
the API succeeded and arrived normally).

There's a local script, `scripts/send_beemail.py`, invoked via two
`make` targets. **It's intentionally not part of this repo** — it's
gitignored, since it's tied to this specific Mailchimp account (audience
ID, from-address) rather than being general site tooling. It only
exists on this machine; back it up somewhere yourself (e.g. a private
repo or your own cloud storage) since losing it means rewriting it from
this description.

What it does: pulls the post's actual rendered content straight from the
live `feed.xml` (so the email always matches what's really published,
images and all), wraps it in a simple branded HTML template (not
Mailchimp's own template system, to sidestep its unrelated
`IFNOT:ARCHIVE_PAGE` template warning), creates a regular (non-RSS,
non-scheduled) campaign — using the post's `description` front matter
as the inbox preview text — and sends it immediately.

1. Write and push the post as normal (steps above) — **this script
   requires the post to already be live**, since it reads from the real
   feed.
2. Send yourself a test first, always:
   ```
   make send-test POST=_posts/2026-11-02-fall-inspection.md
   ```
   This creates a draft campaign and emails only you
   (`marshall.levin@gmail.com` by default; override with
   `--test-email` if calling the script directly). Check formatting,
   images, and every link before going further. The draft campaign is
   left in Mailchimp for you to review or delete — it doesn't count
   against the duplicate-send check below (only `sent`/`sending`
   campaigns do).
3. Once it looks right, send for real:
   ```
   make send-live POST=_posts/2026-11-02-fall-inspection.md
   ```
   This asks for a typed `SEND` confirmation before actually sending to
   the full audience. It also refuses to run at all if a campaign with
   that exact title (`Beemail: <post title>`) was already sent — cheap
   protection against accidentally double-emailing the same post.

The API key path defaults to `~/docs/hive490_mailchimp.txt` (outside
the repo); override with the `MAILCHIMP_API_KEY_FILE` environment
variable if it ever moves.

## Debugging phone-only rendering bugs

Some layout bugs only show up on a real phone browser — notably, text
rendering flush against the screen edge on narrow viewports (fixed
2026-10-17: `.page-main`'s `padding: 2.5rem 0 3rem` shorthand was
zeroing out `.wrap`'s horizontal padding on `<main class="wrap
page-main">`, since both selectors have equal specificity and
`.page-main` came later in the stylesheet — invisible on desktop,
where `.wrap`'s `margin: auto` centering still provides a gutter above
its 760px max-width, but the only source of a side margin below that
width). Resizing a desktop browser window narrow, or Chrome DevTools'
device emulation, didn't reproduce it — the fix had to be confirmed on
an actual device.

For that kind of bug, connect the phone over USB and use the Chrome
DevTools Protocol directly instead of guessing from screenshots:

1. On the phone: enable Developer Options (Settings → About phone →
   tap Build number 7 times), then enable USB debugging (Settings →
   Developer options), connect via USB, and approve the "Allow USB
   debugging" prompt.
2. On the Mac: `adb devices -l` to confirm it shows `device` (not
   `unauthorized`), then `adb forward tcp:9222
   localabstract:chrome_devtools_remote`.
3. `curl http://localhost:9222/json` lists every open tab on the
   phone's Chrome, each with a `webSocketDebuggerUrl`.
4. Connect to that WebSocket URL (Python's `websockets` library works
   well) and send CDP commands as JSON-RPC: `Runtime.evaluate` to pull
   real `getBoundingClientRect()`/`getComputedStyle()` values from the
   live page, `Page.captureScreenshot` for a true device screenshot,
   `Page.reload` with `ignoreCache: true` to force a fresh load after
   a deploy.

This gives real computed values and a real screenshot straight from
the device — far more reliable than eyeballing a photo or trying to
simulate narrow viewports locally.

## Project structure

```
_config.yml       Site settings — title, URL, Mailchimp signup link, plugins
_config_dev.yml   Local-only override (blanks site.url) merged in by make serve/build
_layouts/         default.html (shell), home.html (post list), post.html
_includes/        head.html (SEO/meta/favicons), header.html, footer.html
_posts/           Beemail entries, one file per post
assets/css/       Hand-written CSS (no framework, no Sass pipeline)
assets/images/    Logo, favicons, social-share image, post images
assets/js/        lightbox.js — vanilla JS, no dependencies
index.md          Homepage (uses home.html layout)
about.md          About page
CNAME             Custom domain for GitHub Pages
robots.txt        Points crawlers at sitemap.xml
site.webmanifest  Android/PWA icon metadata
Makefile          make install / serve / build / clean
```
