.PHONY: install serve build clean optimize-image

# Install gems into vendor/bundle (run this once, and again after editing the Gemfile)
install:
	bundle config set --local path 'vendor/bundle'
	bundle install

# Preview the site locally at http://localhost:4000 (rebuilds on save).
# Merges in _config_dev.yml, which blanks out site.url so post images
# don't link out to the live production domain during local preview —
# GitHub Pages builds with _config.yml alone, so it always gets the real
# https://hive490.buzz URLs.
serve:
	bundle exec jekyll serve --livereload --config _config.yml,_config_dev.yml

# Build the static site into _site/ without serving it (same local override
# as `serve` — see above)
build:
	bundle exec jekyll build --config _config.yml,_config_dev.yml

# Remove generated files
clean:
	bundle exec jekyll clean

# Resize/compress a photo before adding it to a post, and strip metadata
# (EXIF, including GPS location). Shrinks to a max of 1600px on the long
# edge — only touches the one file you point it at, never re-processes
# images already in assets/images/.
#
# Usage: make optimize-image SRC=~/Desktop/photo.jpg DEST=assets/images/2026-11-02-example.jpg
optimize-image:
	@if [ -z "$(SRC)" ] || [ -z "$(DEST)" ]; then \
		echo "Usage: make optimize-image SRC=path/to/original.jpg DEST=assets/images/name.jpg"; \
		exit 1; \
	fi
	magick "$(SRC)" -auto-orient -strip -resize '1600x1600>' -quality 82 "$(DEST)"
	@echo "Wrote $(DEST):"
	@du -h "$(DEST)"

# Local-only targets (send-test, send-live) live in Makefile.local, which
# is gitignored and silently skipped if it doesn't exist — see README's
# "Sending an email manually" section for what they do and why they're
# not part of the public repo.
-include Makefile.local
