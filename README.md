# buzzn/core

buzzn/core is the central server-side application of buzzn. It contains the business logic, storage and API for our client/frontend applications.

# Table of contents

<!-- MarkdownTOC autolink=true -->

- [buzzn/core](#buzzncore)
- [Table of contents](#table-of-contents)
- [Application Architecture](#application-architecture)
- [Bin-Scripts](#bin-scripts)
- [Useful rake tasks](#useful-rake-tasks)
  - [Discovergy Credentials](#discovergy-credentials)
  - [Overview](#overview)
  - [Common testing workflow - after checking out a remote branch](#common-testing-workflow---after-checking-out-a-remote-branch)
  - [Common testing workflow - to run one test file](#common-testing-workflow---to-run-one-test-file)
  - [Loading setup and example data ("seeds")](#loading-setup-and-example-data-%22seeds%22)
- [Beekeeper import](#beekeeper-import)
  - [How to run it](#how-to-run-it)
- [How to deploy](#how-to-deploy)
  - [Maintenance Mode](#maintenance-mode)
  - [Deploy staging](#deploy-staging)
  - [Deploy production](#deploy-production)
- [How to set up a development environment](#how-to-set-up-a-development-environment)
  - [Setup Ruby (using rbenv)](#setup-ruby-using-rbenv)
  - [Install required software](#install-required-software)
  - [Set up the project](#set-up-the-project)
  - [Start server in development mode](#start-server-in-development-mode)
  - [Reset and start test environment](#reset-and-start-test-environment)
  - [Set up rubocop](#set-up-rubocop)
    - [How to auto-corrrect rule offenses](#how-to-auto-corrrect-rule-offenses)
    - [How to disable checking a rule locally](#how-to-disable-checking-a-rule-locally)
    - [How to run rubocop before every push automatically](#how-to-run-rubocop-before-every-push-automatically)
- [Misc admin info (may be outdated)](#misc-admin-info-may-be-outdated)
  - [Start sidekiq message queue](#start-sidekiq-message-queue)
  - [Stop sidekiq](#stop-sidekiq)
  - [Find missing Indexes](#find-missing-indexes)
  - [Run analysis of security vulnerabilities](#run-analysis-of-security-vulnerabilities)
- [Further links & documentation](#further-links--documentation)

<!-- /MarkdownTOC -->

# Application Architecture

See [docs/application_architecture.md](docs/application_architecture.md).

# Bin-Scripts

* bin/console - starts application with pry session
* bin/server  - starts puma server
* bin/rake    - runs rake with application bundler context
* bin/rspec   - runs rspec with the current bundler context
* bin/reset_test_db   - runs some rake tasks to reset test DB
* bin/example_data    - runs some rake tasks to setup and seed DB for running local server

you can add `./bin` to your `PATH` to simplely use `console`, `server`, `rake` or `rspec`.

# Useful rake tasks

## Discovergy Credentials

To wire up some datasource of some registers with the discovergy API you need add the credentials in
.env.local

DISCOVERGY_LOGIN=<username from lastpass>
DISCOVERGY_PASSWORD=<password from lastpass>

## Overview

| task name                          | description                                                                                                                | source       |
|------------------------------------|----------------------------------------------------------------------------------------------------------------------------|--------------|
| `rake db:empty`                    | Resets the database without dropping the DB.<br />Useful to reset DB when it has open connections.                         | Buzzn custom |
| `rake db:seed:example_data`        | Load an example localpool into the DB.<br />It does not prepare/empty the DB, run `rake db:empty` beforehands if required. | Buzzn custom |
| `rake db:dump:transfer`            | Transfer relevant data from buzzn_core_development to DATABASE_DUMP_NAME                                                   | Buzzn custom |
| `rake deploy:staging`              | Deploy the application to staging.                                                                                         | Buzzn custom |
| `rake deploy:production`           | Deploy the application to production and create a new release tag.                                                         | Buzzn custom |
| `rake heroku:update_db:staging`    | Import the beekeeper dump locally and push it to staging.                                                                  | Buzzn custom |
| `rake heroku:pull_db:staging`      | Fetch a postgres dump from staging to DATABASE_DUMP_NAME, for use with `db:dump:transfer`                                  |              |
| `rake heroku:update_db:production` | Import the beekeeper dump locally and push it to production.                                                               | Buzzn custom |
| `rake heroku:pull_db:production`   | Fetch a postgres dump from production to DATABASE_DUMP_NAME, for use with `db:dump:transfer`                               |              |

## Common testing workflow - after checking out a remote branch

- checkout the branch
- run `reset_test_db` once to ensure DB is prepared
- run `rspec`

## Common testing workflow - to run one test file

- run `reset_test_db` once to ensure DB is prepared
- run `rspec path/to/spec_file`

## Loading setup and example data ("seeds")

Our application has two kinds of data that we can pre-load ("seed"), *setup* and *example* data.

*Setup* data is essential for any deployment of our application to work. Among others, it loads the buzzn organization into the database (which has hard-coded references in the code as `Organization.buzzn`). It can be loaded by running `rake db:seed:setup_data` on the shell.

*Example* data contains an exemplary localpool, as well as contracts and their users, meters etc.. This data is completely optional and should not be loaded into the production system. We use it for demos or testing where we don't have real user-generated data. Load it into the database by running `rake db:seed:example_data` on the shell.

Use the [list of example users](db/example_data/persons.rb#L6-L21) to log in. Login is the email, the password always is `Example123`.

Note that creating a user account with the buzzn operator role (super user) is not part of the example data. Use the separate rake tasks `db:seed:buzzn_operators` or `db:seed:buzzn_operator` to create one.

**Important**: both rake tasks do not empty the database before running, so when there already is data in the system, there may be conflicts, causing the task to abort.
So if you know what you are doing, run `rake db:empty` first, to completely delete all data from the database.

# Beekeeper import

## How to run it

- make sure your `.env.local` has the correct, safe DEFAULT_ACCOUNT_PASSWORD
- load setup and example data into the local core DB (we need the user accounts)
   - `rake db:empty db:seed:example_data`
- get the latest beekeeper MySQL dumps ("minipool_..." and "buzzndb_2017-11-17_TT.zip")
- convert/load them into separate DBs in local postgres server
    - `rake beekeeper:sql:mysql2postgres FILE=/absolute/path/to/minipooldb_2017-11-17_TT.zip`
    - `rake beekeeper:sql:mysql2postgres FILE=/absolute/path/to/buzzndb_2017-11-17_TT.zip`
    - make sure no table has any errors, (check summary table at the end)
- convert and import that data into the core DB:
    - `rake beekeeper:import`
- optionally upload the local core DB into the Heroku DB
  - `heroku pg:reset`
  - `heroku pg:push buzzn_development DATABASE_URL`

# How to deploy

We're running on Heroku, so you can deploy from Heroku's web interface if you want. To do it from the command line:

## Maintenance Mode

to switch maintenance mode off/on execute the rake tasks on heroku for staging

    `heroku run rake maintenance:on -a buzzn-core-staging`
    `heroku run rake maintenance:on -a buzzn-core-staging`

or for production

    `heroku run rake maintenance:on --remote production`
    `heroku run rake maintenance:off --remote production`

this is important when the DB structure changes and the code and DB have mismatch for some time during deployment.

## Deploy staging

Staging is deployed automatically for every green CI build on `master`.
To do it manually: `rake deploy:staging`.

## Deploy production

Run `rake deploy:production`. This pushes the current branch to Heroku and sets a release tag on the git repo.

_Note on the previous, docker-based system and deployment: the Dockerfiles and related code have been removed, [use this git tag](https://github.com/buzzn/core/tree/before-removing-docker-config) to get them back. The same tag is set in the console app._

# How to set up a development environment

## Setup Ruby (using rbenv)

    See https://github.com/sstephenson/rbenv#installation
    The required version number is found in file .ruby-version

## Install required software
    imagemagick, postgresql, redis
    for postgresql important on linux: 
      Edit the pg_hba.conf file /etc/postgresql/9.5/main/pg_hba.conf
      Change all authentication methods to "trust" and restart Server. 

    use homebrew on a Mac

## Set up the project
  - Grab the source `git clone https://github.com/buzzn/core.git`
  - Get dependencies
    ```bash
    cd core
    gem install bundler
    bundle install
    ```
  - Create a `.env.development`
    ```bash
    # Please keep the variables ordered alphabetically.
    # This file is for overrides of the .env file when running in development.
    ASSET_HOST=http://localhost:3000
    DEFAULT_ACCOUNT_PASSWORD=Example123
    DISPLAY_URL=http://localhost:2999
    SESSION_INACTIVITY_TIMEOUT=31536000 # 1 yearPOSTGRES_HOST=localhost
    POSTGRES_USER=postgres
    POSTGRES_PASSWORD=secret
    POSTGRES_BASE=postgres://$POSTGRES_USER@$POSTGRES_HOST
    DATABASE_URL=$POSTGRES_BASE/buzzn_developmentREDIS_HOST=localhost
    REDIS_CACHE_URL=redis://$REDIS_HOST:6379/0
    REDIS_SIDEKIQ_URL=redis://$REDIS_HOST:6379/1

    MAIL_BACKEND=stdout
    DISCOVERGY_LOGIN=YOUR_DISCOVERGY_LOGIN_NAME
    DISCOVERGY_PASSWORD=YOUR_DISCOVERGY_PASSWORD
    ```
  - Start postgres and and create a database and a user according to the entries of the previous `.env.development`
    ```bash
    createdb -U postgres -h localhost buzzn_development
    pg_restore -h localhost -d buzzn_development -U postgres ./some_data.dump # Import some data if you already have any
    ```
  - Start redis

## Start server in development mode
    bin/server

## Reset and start test environment
    RACK_ENV=test rake db:reset
    guard

## Set up rubocop

We run rubocop in CI to ensure consistent coding style and prevent error-prone syntax. Let your editor check
the rules as well so you don't have to rely on CI.

Here's how to integrate it into editors:
- for SublimeText: https://packagecontrol.io/packages/SublimeLinter-rubocop
- for Atom: https://atom.io/packages/linter-rubocop
- for Emacs: https://github.com/bbatsov/rubocop-emacs

To run rubocop from the CLI, simply type `rubocop`.

### How to auto-corrrect rule offenses

Rubocop is smart enough to auto-corrrect most offenses by running `rubocop -a`

### How to disable checking a rule locally

* For a section of code:

```ruby
# rubocop:disable RuleName
some = Exception(to, the, rule)
# rubocop:enable RuleName
```

### How to run rubocop before every push automatically

Install the [overcommit gem](https://github.com/brigade/overcommit); it'll then use the [.overcommit.yml](.overcommit.yml) file that's already checked in to run rubocop before pushing.

# Misc admin info (may be outdated)

## Start sidekiq message queue
    redis-server
    remark: probably necessary to reinit database (rake db:init) to let sidekiq run properly
    bundle exec sidekiq -r ./config/sidekiq.rb

The (very useful) Sidekiq Admin interface currently isn't set up. See [Sidekiq's documentation on standalone installation](https://github.com/mperham/sidekiq/wiki/Monitoring#standalone) for how to enable it.

## Stop sidekiq
    rake sidekiq:kill

## Find missing Indexes
    lol_dba db:find_indexes

## Run analysis of security vulnerabilities
    brakeman

# Further links & documentation

* [Buzzn API](https://github.com/buzzn/buzzn/blob/master/docs/api.md)
* [NewRelic](https://rpm.newrelic.com/accounts/791323/servers)
* [Data Model](https://www.lucidchart.com/documents/edit/023ef2a3-0b1d-4740-a202-4ad868f3c098)
* [Overview over Groups, Registers, their User's roles and Invitation flow](https://www.lucidchart.com/documents/edit/0a16d140-934c-4f50-b730-7d6684162232/0)
* [Privacy Settings (readability) of Resources](https://docs.google.com/spreadsheets/d/13NtNstj4AVEbxvXTEgx6Hit-g0NHsS7Uy5JPYceETjI/edit#gid=0)
* [All Notifications & their User Groups](https://docs.google.com/spreadsheets/d/1OPsKFke9NGUYPtWs7Nv5Iv4hMAvqpmYvCPtXEhPhYL4/edit#gid=0)
* [Overview over treating notifications on backend side](https://www.lucidchart.com/documents/edit/7f412806-aa84-46d6-93c7-76bedebd47d9)
