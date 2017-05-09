source 'https://rubygems.org'

# infrastructure
gem 'dry-auto_inject'

# pdf
gem 'slim'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# storage
gem 'fog-aws', require: 'fog/aws'
gem 'fog-local', require: 'fog/local'

# Backend
gem 'active_model_serializers'
gem 'rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'therubyracer'
gem 'uglifier'
gem 'money-rails'
gem 'pg'
gem 'sinatra'
gem 'mongoid'
gem 'moped'
gem 'redis-rails'
gem 'redis-namespace'
gem 'bson'
gem 'puma'
gem 'has_scope'
gem 'awesome_print'
gem 'mail_view'
gem 'devise'
gem 'devise_invitable'
gem 'devise-i18n'
gem 'devise-i18n-views'
gem 'devise-async'
gem 'grape'
gem 'grape-swagger'
gem 'grape-swagger-rails',     github: 'mkristian/grape-swagger-rails', branch: 'oauth'
gem 'rack-cors',               require: 'rack/cors'
gem 'hashie-forbidden_attributes'
gem 'doorkeeper'
gem 'rack-oauth2'
gem 'bcrypt'
gem 'rails-i18n'
gem 'authority'
gem 'rolify'
gem 'ffaker'
gem 'friendly_id'
gem 'immigrant'
gem 'mini_magick'
gem 'carrierwave'
gem 'fog'
gem 'aws-sdk'
gem 'aws-sdk-rails'
gem 'whenever', require: false
gem 'sidekiq'
gem 'faraday'
gem 'attribute_normalizer',       github: 'mdeering/attribute_normalizer'
gem 'geocoder'
gem 'jbuilder'
gem 'paper_trail'
gem 'acts_as_commentable_with_threading'
gem 'awesome_nested_set'
gem 'acts-as-taggable-on'
gem 'public_activity'
gem 'tzinfo'
gem 'ancestry'
gem 'attr_encrypted', '1.3.5'
gem 'acts_as_list'
gem 'iban-tools'
gem 'lograge'
gem 'byebug'
gem 'acts_as_votable'
gem 'multi_json'
gem 'oj'
gem 'oauth'
gem 'remote_lock'
gem 'fabrication'



group :production, :staging do
  gem 'newrelic_rpm'
  gem 'asset_sync'
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
  gem 'database_cleaner'
  gem 'timecop'
  gem 'rspec-retry'
  gem 'webmock'
end
