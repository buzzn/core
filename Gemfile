source 'https://rubygems.org'
ruby '2.3.7'

# transient dependency of rails with security issue, pick secure one
gem 'loofah', '~> 2.2.1'
gem 'rails-html-sanitizer', '~> 1.0.4'
gem 'sprockets', '~> 3.7.2'

# infrastructure
gem 'dry-auto_inject'
gem 'dry-validation'
gem 'dry-monads'
gem 'dry-transaction'
gem 'dry-struct'
gem 'dry-initializer'
gem 'dry-dependency-injection'
gem 'dry-types', '~> 0.12.3'

# pdf
gem 'slim'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary-edge', '~> 0.12.4.0'

# storage
gem 'fog-aws'
gem 'magic'

# authentication
gem 'rodauth'
gem 'bcrypt'
gem 'jwt'

# postgres
gem 'schema_plus_enums'
gem 'pg', '0.20.0'
gem 'pgreset' # Automatically kill postgres connections during db:reset

# json
gem 'multi_json'
gem 'oj'

# background / message queue
gem 'sidekiq'

# iso-3166, etc
gem 'validates_zipcode'
gem 'countries'
gem 'iban-tools'
gem 'ruby_regex'

# discovergy
gem 'oauth'

# metrics
gem 'leafy'
gem 'concurrent-ruby-ext'

# Backend
gem 'puma'
gem 'roda'
gem 'activerecord', '< 5'
gem 'redis'
gem 'rack-cors', require: 'rack/cors'
gem 'clockwork'
gem 'mail'
gem 'ffaker' # using ffaker instead of faker because it has German fakers.
gem 'mini_magick'
gem 'carrierwave'
gem 'faraday'
gem 'jbuilder'
gem 'remote_lock'
gem 'factory_girl'
gem 'dotenv'
gem 'smarter_csv'
gem 'sentry-raven' # the Sentry exception notification service
gem 'rake'
gem 'rails', '< 5'

# bin/console
gem 'pry'

# Injected by Heroku, we might as well include it here directly
gem 'rails_12factor'

group :production, :staging do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'pry-byebug'
  gem 'awesome_print'
  gem 'brakeman', :require => false
  gem 'listen'
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-bundler'
  gem 'guard-brakeman'
  gem 'guard-rspec'
  gem 'fog-local'
  gem 'rubocop', require: false
end

group :test do
  gem 'ruby-swagger'
  gem 'rspec_nested_transactions'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'timecop'
end
