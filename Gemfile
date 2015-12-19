source 'https://rubygems.org'

gem 'rails', '4.2.5'
gem 'mysql2'

# Stylesheets
gem 'sass-rails', '~> 5.0'      # Use SCSS for stylesheets
gem 'bourbon'                   # Mixin Library

# Javascripts
gem 'uglifier', '>= 1.3.0'      # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', '~> 4.1.0'  # Use CoffeeScript for .coffee assets and views
gem 'jquery-rails'              # Use jquery as the JavaScript library
gem 'turbolinks'                # Turbolinks makes links in your application faster

# Web Scraping
gem 'capybara'                  # Simulate user interactions
gem 'poltergeist'               # PhantomJS driver for Capybara
gem 'dsl'                       # Create custom Domain-Specific-Languages
gem 'metainspector'             # Intellegently scrape and parse page content
gem 'whois'                     # Gather Whois information for each domain

# API
gem 'rails-api'                 # Will be merged in Rails 5
gem 'jbuilder', '~> 2.0'        # Build JSON APIs with ease
gem 'acts-as-taggable-on'       # Nice way to keep track of tags

# Authentication
gem 'bcrypt', '~> 3.1.7'        # Use ActiveModel has_secure_password

# Testing                       # Use faker for mock data
gem 'faker', git: 'https://github.com/stympy/faker.git', tag: 'v1.6.1'

# Deployment
gem 'capistrano-rails'          # Use Capistrano for deployment

# Convenience
gem 'awesome_print'             # Better console output

#########################################
# Environments
#########################################

group :development, :test do
  gem 'byebug'                  # Halt execution and debug code anywhere
end

group :development do
  gem 'web-console', '~> 2.0'   # Access IRB on exceptions or <%= console %> in views
  gem 'quiet_assets'            # Hush them asset calls
  gem 'better_errors'           # Better error pages for debugging
  gem 'guard'                   # Handle filesystem events
  gem 'guard-bundler'           # Bundle gems on Gemfile changes
  gem 'guard-pow'               # Restart pow server when needed
end
