[ ![Codeship Status for buzzn/buzzn](https://codeship.io/projects/9ea4e2c0-381a-0132-1daa-26b918746a8c/status)](https://codeship.io/projects/41893)

# buzzn.net

## Setup Ruby with rbenv
    https://github.com/sstephenson/rbenv#installation
    version number found in file .ruby-version

## install software
    mysql
    phantomjs
    imagemagick
    graphviz
    gem install bundler
    gem install mailcatcher

## Setup Rails Project
    git clone git@github.com:ffaerber/buzzn.git
    cd buzzn
    bundle install
    bundle exec rake db:create

## Reset end Start Develoment Environment
    bundle exec rake db:init
    bundle exec rails s

## Reset end Start Test Environment
    bundle exec rake test:prepare
    bundle exec guard

## Reset end Start Test Environment
    bundle exec rake db:init
    bundle exec rake db:test:prepare
    bundle exec guard

## Start Background Jobs
    redis-server
    bundle exec rake sidekiq:start
    http://localhost:3000/sidekiq

## Stop Background Jobs
    bundle exec rake sidekiq:stop

## update meters
    bundle exec rake meter:update

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

## update locales
    bundle exec rails g devise:views:locale de
    bundle exec rails g devise:views:locale en

## add Sublime Settings to Preferences -> File Settings - User:
    "draw_white_space": "selection",
    "trim_trailing_white_space_on_save": true,
    "tab_size": 2,
    "translate_tabs_to_spaces": true,
    "tab_completion": true,
    "save_on_focus_lost": true,
    "highlight_line": true

## Troubleshooting
    bundle exec rake sidekiq:stop
    delete folder vendor/bundle
    bundle install
    gem update rake

## SaaS
    https://rpm.newrelic.com/accounts/791323/servers
    https://trello.com/b/SuonZHEd/buzzn-kanban
    https://codeship.io/projects/41893



