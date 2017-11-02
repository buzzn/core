source 'https://rubygems.org'

# infrastructure
gem 'dry-auto_inject'
gem 'dry-validation'
gem 'dry-monads'
gem 'dry-transaction'
gem 'dry-struct'
gem 'dry-initializer'
# TODO if we are going to use this singleton container then me (christian) needs to publish/push this gem and use it via rubygems.org
gem 'dry-more-container', git: 'https://github.com/mkristian/dry-more-container.git'

# pdf
gem 'slim'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# storage
gem 'fog-aws', require: 'fog/aws'
gem 'fog-local', require: 'fog/local'

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
gem 'pg'

# json
gem 'multi_json'
gem 'oj'

# iso-3166, etc
gem 'validates_zipcode'
gem 'countries'
gem 'iban-tools'

# discovergy
gem 'oauth'

# Backend
gem 'rails'
gem 'money-rails'
gem 'activerecord-nulldb-adapter'
gem 'mongoid'
gem 'redis'
gem 'redis-namespace'
gem 'puma'
gem 'awesome_print'
gem 'mail_view'
gem 'rack-cors',               require: 'rack/cors'
gem 'rolify'
gem 'ffaker' # using ffaker instead of faker because it has German fakers.
gem 'mini_magick'
gem 'carrierwave'
gem 'aws-sdk'
gem 'aws-sdk-rails'
gem 'whenever', require: false
gem 'clockwork'
gem 'sidekiq'
gem 'faraday'
gem 'attribute_normalizer'
gem 'geocoder'
gem 'jbuilder'
gem 'acts_as_commentable_with_threading'
gem 'awesome_nested_set'
gem 'attr_encrypted', '1.3.5'
gem 'byebug'
gem 'remote_lock'
gem 'fabrication'
gem 'factory_girl'
gem 'dotenv-rails'
gem 'smarter_csv'

group :production, :staging do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'brakeman', :require => false
  gem 'lol_dba'
  gem 'listen'
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-bundler'
  gem 'guard-brakeman'
  gem 'guard-rspec'
end

group :development do
  gem 'pry-rails'
  gem 'annotate'
  gem 'yard'
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
