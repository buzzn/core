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

## Setup Rails Project
    git clone git@github.com:ffaerber/buzzn.git
    cd buzzn
    add /config/secrets.yml (ask the Lead Developer)
    bundle install
    bundle exec rake db:create

## Reset end Start Develoment Environment
    bundle exec rake db:init
    bundle exec rails s

## Reset end Start Test Environment
    bundle exec rake db:init
    bundle exec rake db:test:prepare
    bundle exec guard

## Start Background Jobs
    redis-server
    bundle exec sidekiq -q high, 5 default
    http://localhost:3000/sidekiq

## update meters
    bundle exec rake smartmeter:register_update

## Mail Views
    http://localhost:3000/de/mail_view

## Mail Catcher
    bundle exec mailcatcher
    http://127.0.0.1:1080

## Find missing Indexes
    bundle exec lol_dba db:find_indexes

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
    delete folder vendor/bundle
    bundle install
    gem update rake