.PHONY: install serve build clean

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
