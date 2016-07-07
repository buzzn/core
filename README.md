[ ![Codeship Status for buzzn/buzzn](https://codeship.io/projects/9ea4e2c0-381a-0132-1daa-26b918746a8c/status)](https://codeship.io/projects/41893)

# buzzn.net

## Setup Ruby with rbenv
    https://github.com/sstephenson/rbenv#installation
    version number found in file .ruby-version

## install software
    imagemagick, mongodb, postgresql, redis

## Setup Rails Project
    git clone git@github.com:ffaerber/buzzn.git
    cd buzzn
    gem install bundler
    gem install mailcatcher
    bundle install
    bundle exec rake db:create

## Reset end Start Develoment Environment
    bundle exec rake db:init
    bundle exec rails s

## Reset end Start Test Environment
    bundle exec rake db:init
    bundle exec rake db:test:prepare
    bundle exec guard

## Sidekiq Start
    redis-server
    remark: probably necessary to reinit database (bundle exec rake db:init) to let sidekiq run properly
    bundle exec rake sidekiq:start
    remark: you must be logged in with admin rights to visit:
    http://localhost:3000/sidekiq

## Sidekiq Kill
    bundle exec rake sidekiq:kill

## Mail Views
    http://localhost:3000/de/mail_view

## Mail Catcher
    mailcatcher
    http://127.0.0.1:1080

## Find missing Indexes
    bundle exec lol_dba db:find_indexes

## Find missing foreign keys
    bundle exec rails generate immigration AddKeys

## Analysis security vulnerability in this app
    bundle exec brakeman

## Troubleshooting
    bin/spring stop
    delete folder vendor/bundle
    bundle install

## SaaS
    https://rpm.newrelic.com/accounts/791323/servers
    https://trello.com/b/SuonZHEd/buzzn-kanban
    https://codeship.io/projects/41893

# create API token via API
    #https://github.com/doorkeeper-gem/doorkeeper/wiki/Testing-your-provider-with-OAuth2-gem
    app = Doorkeeper::Application.last
    client_redirect_url = 'urn:ietf:wg:oauth:2.0:oob'
    client = OAuth2::Client.new(app.uid, app.secret, site: "http://localhost:3000")
    client.auth_code.authorize_url(scope: app.scopes, redirect_uri: client_redirect_url)
    token = client.auth_code.get_token('xxxxxxxxxx', redirect_uri: client_redirect_url)
    access_token = token.token

# create API token via rails console
    open or create oauth Application https://staging.buzzn.net/oauth/applications
    get id of application and go to rails console
    application = Doorkeeper::Application.find('2a81c128-ef09-4c21-b779-f2655b38d1b4')
    user = User.where(email: 'felix@buzzn.net').first
    access_token = Doorkeeper::AccessToken.create(application_id: application.id, resource_owner_id: user.id, scopes: 'public admin' )
    go to https://staging.buzzn.net/access_tokens to view generated tokens

## Docs
  Data Model:
  https://www.lucidchart.com/documents/edit/023ef2a3-0b1d-4740-a202-4ad868f3c098
  Overview over Groups, MeteringPoints, their User's roles and Invitation flow:
  https://www.lucidchart.com/documents/edit/0a16d140-934c-4f50-b730-7d6684162232/0
  Privacy Settings (readability) of Resources:
  https://docs.google.com/spreadsheets/d/13NtNstj4AVEbxvXTEgx6Hit-g0NHsS7Uy5JPYceETjI/edit#gid=0
  All Notifications & their User Groups:
  https://docs.google.com/spreadsheets/d/1OPsKFke9NGUYPtWs7Nv5Iv4hMAvqpmYvCPtXEhPhYL4/edit#gid=0
  Overview over treating notifications on backend side:
  https://www.lucidchart.com/documents/edit/7f412806-aa84-46d6-93c7-76bedebd47d9
  
  
