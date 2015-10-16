[ ![Codeship Status for buzzn/buzzn](https://codeship.io/projects/9ea4e2c0-381a-0132-1daa-26b918746a8c/status)](https://codeship.io/projects/41893)

# buzzn.net

## Setup Ruby with rbenv
    https://github.com/sstephenson/rbenv#installation
    version number found in file .ruby-version

## install software
    phantomjs
    imagemagick
    graphviz
    sudo apt-get install postgresql postgresql-contrib
    create superuser on psql: sudo -u postgres createuser -s -d thomas
    sudo apt-get install mongodb
    sudo apt-get install apache2
    mkdir slanger
    cd slanger
    ../.rbenv/versions/2.2.2/bin/gem install slanger

    recommended: apt-get install git-cola
    start git-cola with LANG=c && git-cola to skip strange german translations of push etc.

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
    bundle exec rake test:prepare
    bundle exec guard

## Reset end Start Test Environment
    bundle exec rake db:init
    bundle exec rake db:test:prepare
    bundle exec guard

## Start Slanger(OpenSource Pusher.com)
    from outside the rails project folder
    cd slanger
    slanger --app_key 83f4f88842ce2dc76b7b --secret 7c4cfa157cd37a4b35bb

## Sidekiq Start
    redis-server
    remark: probably necessary to reinit database (bundle exec rake db:init) to let sidekiq run properly
    bundle exec rake sidekiq:start
    remark: you must be logged in with admin rights to visit:
    http://localhost:3000/sidekiq

## Sidekiq Kill
    bundle exec rake sidekiq:kill

## pull_readings meters
    bundle exec rake meter:pull_readings

## reactivate meters
    bundle exec rake meter:reactivate

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

## add Sublime Settings to Preferences -> Settings - User:
    "draw_white_space": "selection",
    "trim_trailing_white_space_on_save": true,
    "tab_size": 2,
    "translate_tabs_to_spaces": true,
    "tab_completion": true,
    "save_on_focus_lost": true,
    "highlight_line": true

## Troubleshooting
    bin/spring stop
    delete folder vendor/bundle
    bundle install

## SaaS
    https://rpm.newrelic.com/accounts/791323/servers
    https://trello.com/b/SuonZHEd/buzzn-kanban
    https://codeship.io/projects/41893

## API
    get api token
    client = OAuth2::Client.new('a71d41c4ed35cc0f1fcc71624e2dedb944bb0f5b08f28ba5ca1e414080d27944', '7f60d77d9cd7bbce803f90fce6075b1a346322a3ddd31b05409d9b26374f368a', :site => "http://localhost:3000")
    client.password.get_token('felix@buzzn.net', '12345678').token

    go to http://localhost:3000/api
    add token and explore api
