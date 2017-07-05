source 'https://rubygems.org'

# infrastructure
gem 'dry-auto_inject'
gem 'dry-validation'
gem 'dry-monads'
gem 'dry-transaction'

# pdf
gem 'slim'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# storage
gem 'fog-aws', require: 'fog/aws'
gem 'fog-local', require: 'fog/local'

# activeadmin
gem 'activeadmin'
gem 'select2-rails'
gem 'activeadmin-select2'

# swagger
gem 'ruby-swagger'

# roda
gem 'roda'
gem 'newrelic-roda'

# Backend
gem 'rails'
gem 'sprockets-rails'
gem 'simple_form'
gem 'jquery-rails'
gem 'haml-rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'therubyracer'
gem 'uglifier'
gem 'money-rails'
gem 'pg'
gem 'activerecord-nulldb-adapter'
gem 'mongoid'
gem 'moped'
gem 'redis-rails'
gem 'redis-namespace'
gem 'puma'
gem 'awesome_print'
gem 'mail_view'
gem 'devise'
gem 'devise_invitable'
gem 'devise-i18n'
gem 'devise-i18n-views'
gem 'devise-async'
gem 'rack-cors',               require: 'rack/cors'
gem 'doorkeeper'
gem 'rolify'
gem 'ffaker'
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
gem 'paper_trail'
gem 'acts_as_commentable_with_threading'
gem 'awesome_nested_set'
gem 'attr_encrypted', '1.3.5'
gem 'iban-tools'
gem 'byebug'
gem 'acts_as_votable'
gem 'multi_json'
gem 'oj'
gem 'oauth'
gem 'remote_lock'
gem 'fabrication'
gem 'dotenv-rails'


group :production, :staging do
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'brakeman', :require => false
  gem 'lol_dba'
  gem 'listen'
  gem 'launchy'
end

group :development do
  gem 'pry-rails'
  gem 'quiet_assets'
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
  gem 'guard'
  gem 'guard-livereload'
  gem 'guard-bundler'
  gem 'guard-brakeman'
  gem 'guard-rspec'
  gem 'timecop'
  gem 'rspec-retry'
  gem 'webmock'
end
