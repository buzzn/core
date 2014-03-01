# buzzn.net

## install software
    mysql
    phantomjs
    imagemagick
    graphviz

## Setup Ruby with rbenv
    https://github.com/sstephenson/rbenv#installation
    version number found under in file .ruby-version

## Setup Rails Project
    git clone git@github.com:ffaerber/buzzn.git
    cd buzzn
    bundle install
    bundle exec rake db:create

## Reset end Start Develoment Environment
    bundle exec rake db:init
    bundle exec rails s

## Reset end Start Test Environment
    bundle exec rake db:init
    bundle exec rake db:test:prepare
    bundle exec guard

## Mail Views
    http://localhost:3000/de/mail_view

## Mail Catcher
    bundle exec mailcatcher
    http://127.0.0.1:1080

## Find missing Indexes
    bundle exec lol_dba db:find_indexes

## Analysis security vulnerability in this app
    bundle exec brakeman

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