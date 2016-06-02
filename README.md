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
    bundle exec rescue rspec

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

## API
    #https://github.com/doorkeeper-gem/doorkeeper/wiki/Testing-your-provider-with-OAuth2-gem
    app = Doorkeeper::Application.last
    client_redirect_url = 'urn:ietf:wg:oauth:2.0:oob'
    client = OAuth2::Client.new(app.uid, app.secret, site: "http://localhost:3000")
    client.auth_code.authorize_url(scope: app.scopes, redirect_uri: client_redirect_url)
    token = client.auth_code.get_token('xxxxxxxxxx', redirect_uri: client_redirect_url)
    access_token = token.token

## TODO
  - rails controller den neuen Aggregator benuzten lassen.
  - rake slp und co auf milli_watt ändern
  - remove discovergy pull readings
  - mongodb TTL 4 jahre.
  - fix swagger ui
  - fix google anlytics 

## Docs
  https://docs.google.com/spreadsheets/d/1OPsKFke9NGUYPtWs7Nv5Iv4hMAvqpmYvCPtXEhPhYL4/edit#gid=0
  https://docs.google.com/spreadsheets/d/1_KMXlYH3xcPKXx1p_RxxuLe6wP1pI-P2gOcJu7_rUNs/edit?ts=574ef7ae#gid=0
