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

## API
    - All endpoints can be found under [/api](http://localhost:3000/api)
    - The JSON is follows the [JSONAPI](http://jsonapi.org/) Specification.
    - Auth is implementet via [OAuth2](https://www.digitalocean.com/community/tutorials/an-introduction-to-oauth-2).
    - Under [/oauth/applications](http://localhost:3000/oauth/applications) you can register a new OAuth Client/Application.
    - [Test the Auth with OAuth2.gem Client](https://github.com/doorkeeper-gem/doorkeeper/wiki/Testing-your-provider-with-OAuth2-gem).
    - To build a Application without Client Secret Key (for example a JavaScript [SPA](https://en.wikipedia.org/wiki/Single-page_application) you can use the [/api/v1/auth/token](http://localhost:3000/api#!/v1/postApiV1AuthToken) endpoint to exchange a AuthorizationCode to an AccessToken.

## Docs
    - [KanBan Board](https://waffle.io/buzzn/buzzn)
    - [NewRelic](https://rpm.newrelic.com/accounts/791323/servers)
    - [Data Model](https://www.lucidchart.com/documents/edit/023ef2a3-0b1d-4740-a202-4ad868f3c098)
    - [Overview over Groups, MeteringPoints, their User's roles and Invitation flow](https://www.lucidchart.com/documents/edit/0a16d140-934c-4f50-b730-7d6684162232/0)
    - [Privacy Settings (readability) of Resources](https://docs.google.com/spreadsheets/d/13NtNstj4AVEbxvXTEgx6Hit-g0NHsS7Uy5JPYceETjI/edit#gid=0)
    - [All Notifications & their User Groups](https://docs.google.com/spreadsheets/d/1OPsKFke9NGUYPtWs7Nv5Iv4hMAvqpmYvCPtXEhPhYL4/edit#gid=0)
    - [Overview over treating notifications on backend side](https://www.lucidchart.com/documents/edit/7f412806-aa84-46d6-93c7-76bedebd47d9)
