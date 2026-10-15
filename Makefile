.PHONY: install serve build clean optimize-image

# Install gems into vendor/bundle (run this once, and again after editing the Gemfile)
install:
	bundle config set --local path 'vendor/bundle'
	bundle install

# Preview the site locally at http://localhost:4000 (rebuilds on save)
serve:
	bundle exec jekyll serve --livereload

# Build the static site into _site/ without serving it
build:
	bundle exec jekyll build

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
