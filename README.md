# buzzn core

Production | Staging
--- | ---
https://app.buzzn.com | https://staging.buzzn.com
[ ![Codeship Status for buzzn/kiosk](https://app.codeship.com/projects/9ea4e2c0-381a-0132-1daa-26b918746a8c/status?branch=release)](https://app.codeship.com/projects/41893) | [ ![Codeship Status for buzzn/kiosk](https://app.codeship.com/projects/9ea4e2c0-381a-0132-1daa-26b918746a8c/status?branch=master)](https://app.codeship.com/projects/41893)

## Application Architecture

See [docs/application_architecture.md](docs/application_architecture.md).

## Useful rake tasks

| task name            | description   | source
|----------------------|---------------|----------------
| `rake`               | Run all tests | Rails default
| `rake test:prepare`      | Prepare the DB for testing, i.e. drop and recreate it, and load the schema | Buzzn custom
| `rake db:reset`      | Drop and recreate the DB, load schema and setup data | Rails default
| `rake db:empty` | Resets the database without dropping the DB.<br />Useful to reset DB when it has open connections. | Buzzn custom
| `rake db:seed:example_data` | Load an example localpool into the DB.<br />It does not prepare/empty the DB, run `rake db:empty` beforehands if required. | Buzzn custom

##### Common testing workflow - after checking out a remote branch

- checkout the branch
- run `RAILS_ENV=test rake db:reset` once to ensure DB is prepared
- run `rake`

##### Common testing workflow - to run one test file

- run `RAILS_ENV=test rake db:reset` once to ensure DB is prepared
- run `rspec path/to/spec_file`

## Loading setup and example data ("seeds")

Our application has two kinds of data that we can pre-load ("seed"), *setup* and *example* data.

*Setup* data is essential for any deployment of our application to work. Among others, it loads the buzzn organization into the database (which has hard-coded references in the code as `Organization.buzzn`). It can be loaded by running `rake db:seed:setup_data` on the shell.

*Example* data contains an exemplary localpool, as well as contracts and their users, meters etc.. This data is completely optional and should not be loaded into the production system. We use it for demos or testing where we don't have real user-generated data. Load it into the database by running `rake db:seed:example_data` on the shell.

Use the [list of example users](db/example_data/persons.rb#L6-L21) to log in. Login is the email, the password always is `Example123`.

**Important**: both rake tasks do not empty the database before running, so when there already is data in the system, there may be conflicts, causing the task to abort.
So if you know what you are doing, run `rake db:empty` first, to completely delete all data from the database.

## How to deploy

This description is for staging, production should work the same once it's implemented.

1. We're running on Heroku, so first do this one-time setup:

- `git remote add staging https://git.heroku.com/buzzn-core-staging.git` 
- `heroku login` (make sure it succeeds / you are a collaborator on the app)

2. run `git push staging {your-local-branch}:master`

_Note on the previous, docker-based system and deployment: the Dockerfiles and related code have been removed, [use this git tag](https://github.com/buzzn/core/tree/before-removing-docker-config) to get them back. The same tag is set in the console app._

## Setup Ruby with rbenv

    https://github.com/sstephenson/rbenv#installation
    version number found in file .ruby-version

## Install software
    imagemagick, mongodb, postgresql, redis

## Setup Rails Project
    git clone https://github.com/buzzn/buzzn.git
    cd buzzn
    gem install bundler
    bundle install
    bundle exec rake db:create db:structure:load db:seed:setup_data

## Reset and Start Develoment Environment
    bundle exec rails s

## Reset and Start Test Environment
    RAILS_ENV=test bundle exec rake db:create db:structure:load
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
    delete folder vendor/bundle
    bundle install

## Docs
  - [Buzzn OAuth2](https://github.com/buzzn/buzzn/blob/master/docs/auth.md)
  - [Buzzn API](https://github.com/buzzn/buzzn/blob/master/docs/api.md)
  - [NewRelic](https://rpm.newrelic.com/accounts/791323/servers)
  - [Data Model](https://www.lucidchart.com/documents/edit/023ef2a3-0b1d-4740-a202-4ad868f3c098)
  - [Overview over Groups, Registers, their User's roles and Invitation flow](https://www.lucidchart.com/documents/edit/0a16d140-934c-4f50-b730-7d6684162232/0)
  - [Privacy Settings (readability) of Resources](https://docs.google.com/spreadsheets/d/13NtNstj4AVEbxvXTEgx6Hit-g0NHsS7Uy5JPYceETjI/edit#gid=0)
  - [All Notifications & their User Groups](https://docs.google.com/spreadsheets/d/1OPsKFke9NGUYPtWs7Nv5Iv4hMAvqpmYvCPtXEhPhYL4/edit#gid=0)
  - [Overview over treating notifications on backend side](https://www.lucidchart.com/documents/edit/7f412806-aa84-46d6-93c7-76bedebd47d9)
 Hello