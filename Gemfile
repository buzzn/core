source 'https://rubygems.org'
ruby '2.3.1'

# infrastructure
gem 'dry-auto_inject'
gem 'dry-validation'
gem 'dry-monads'
gem 'dry-transaction'
gem 'dry-struct'
gem 'dry-initializer'
gem 'dry-dependency-injection'

# pdf
gem 'slim'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# storage
gem 'fog-aws'

# swagger
gem 'ruby-swagger'

# roda
gem 'roda'

# authentication
gem 'rodauth'
gem 'bcrypt'
gem 'jwt'

# postgres
gem 'schema_plus_enums'
gem 'pg', '0.20.0'

# json
gem 'multi_json'
gem 'oj'

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
gem 'rails', '< 5'
gem 'mongoid'
gem 'redis'
gem 'rack-cors', require: 'rack/cors'
gem 'clockwork'
gem 'money-rails'
gem 'redis-namespace'             # ???
gem 'ffaker' # using ffaker instead of faker because it has German fakers.
gem 'mini_magick'
gem 'carrierwave'
gem 'faraday'
gem 'jbuilder'
gem 'remote_lock'
gem 'fabrication'
gem 'factory_girl'
gem 'dotenv-rails'
gem 'smarter_csv'

# bin/console
gem 'pry'

# Injected by Heroku, we might as well include it here directly
gem 'rails_12factor'


group :production, :staging do
  gem "sentry-raven" # the Sentry exception notification service
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

group :development do
  gem 'pry-rails'
  gem 'rake'
end

group :test do
  gem 'rspec_nested_transactions'
  gem 'vcr'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'rspec-rails'
  gem 'email_spec'
  gem 'timecop'
  gem 'rspec-retry'
  gem 'webmock'
end
