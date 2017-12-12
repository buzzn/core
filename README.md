# buzzn/core

buzzn/core is the central server-side application of buzzn. It contains the business logic, storage and API for our client/frontend applications.

# Table of contents

<!-- MarkdownTOC autolink=true -->

- [Application Architecture](#application-architecture)
- [Useful rake tasks](#useful-rake-tasks)
  - [Discovergy Credentials](#discovergy-credentials)
  - [Overview](#overview)
  - [Common testing workflow - after checking out a remote branch](#common-testing-workflow---after-checking-out-a-remote-branch)
  - [Common testing workflow - to run one test file](#common-testing-workflow---to-run-one-test-file)
  - [Loading setup and example data \("seeds"\)](#loading-setup-and-example-data-seeds)
- [Beekeeper import](#beekeeper-import)
  - [How to run it](#how-to-run-it)
- [How to deploy](#how-to-deploy)
- [How to set up a development environment](#how-to-set-up-a-development-environment)
  - [Setup Ruby \(using rbenv\)](#setup-ruby-using-rbenv)
  - [Install required software](#install-required-software)
  - [Setup the rails Project](#setup-the-rails-project)
  - [Start Rails server in develoment mode](#start-rails-server-in-develoment-mode)
  - [Reset and Start Test Environment](#reset-and-start-test-environment)
- [Misc admin info](#misc-admin-info)
  - [Start sidekiq message queue](#start-sidekiq-message-queue)
  - [Stop sidekiq](#stop-sidekiq)
  - [Find missing Indexes](#find-missing-indexes)
  - [Run analysis of security vulnerabilities](#run-analysis-of-security-vulnerabilities)
- [Troubleshooting](#troubleshooting)
- [Further links & documentation](#further-links--documentation)

<!-- /MarkdownTOC -->

# Application Architecture

See [docs/application_architecture.md](docs/application_architecture.md).

# Useful rake tasks

## Discovergy Credentials

To wire up some datasource of some registers with the discovergy API you need add the credentials in
.env.local

DISCOVERGY_LOGIN=<username from lastpass>
DISCOVERGY_PASSWORD=<password from lastpass>

## Overview

| task name            | description   | source
|----------------------|---------------|----------------
| `rake`               | Run all tests | Rails default
| `rake test:prepare`      | Prepare the DB for testing, i.e. drop and recreate it, and load the schema | Buzzn custom
| `rake db:reset`      | Drop and recreate the DB, load schema and setup data | Rails default
| `rake db:empty` | Resets the database without dropping the DB.<br />Useful to reset DB when it has open connections. | Buzzn custom
| `rake db:seed:example_data` | Load an example localpool into the DB.<br />It does not prepare/empty the DB, run `rake db:empty` beforehands if required. | Buzzn custom

## Common testing workflow - after checking out a remote branch

- checkout the branch
- run `RAILS_ENV=test rake db:reset` once to ensure DB is prepared
- run `rake`

## Common testing workflow - to run one test file

- run `RAILS_ENV=test rake db:reset` once to ensure DB is prepared
- run `rspec path/to/spec_file`

## Loading setup and example data ("seeds")

Our application has two kinds of data that we can pre-load ("seed"), *setup* and *example* data.

*Setup* data is essential for any deployment of our application to work. Among others, it loads the buzzn organization into the database (which has hard-coded references in the code as `Organization.buzzn`). It can be loaded by running `rake db:seed:setup_data` on the shell.

*Example* data contains an exemplary localpool, as well as contracts and their users, meters etc.. This data is completely optional and should not be loaded into the production system. We use it for demos or testing where we don't have real user-generated data. Load it into the database by running `rake db:seed:example_data` on the shell.

Use the [list of example users](db/example_data/persons.rb#L6-L21) to log in. Login is the email, the password always is `Example123`.

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

This description is for staging, production should work the same once it's implemented.

1. We're running on Heroku, so first do this one-time setup:

- `git remote add staging https://git.heroku.com/buzzn-core-staging.git` 
- `heroku login` (make sure it succeeds / you are a collaborator on the app)

2. run `git push staging {your-local-branch}:master`

_Note on the previous, docker-based system and deployment: the Dockerfiles and related code have been removed, [use this git tag](https://github.com/buzzn/core/tree/before-removing-docker-config) to get them back. The same tag is set in the console app._

# How to set up a development environment

## Setup Ruby (using rbenv)

    See https://github.com/sstephenson/rbenv#installation
    The required version number is found in file .ruby-version

## Install required software
    imagemagick, mongodb, postgresql, redis
    use homebrew on a Mac

## Setup the rails Project
    git clone https://github.com/buzzn/core.git
    cd core
    gem install bundler
    bundle install
    rake db:create db:structure:load db:seed:example_data

## Start Rails server in develoment mode
    rails server # also "rails s"

## Reset and Start Test Environment
    rake test:prepare
    guard

# Misc admin info

## Start sidekiq message queue
    redis-server
    remark: probably necessary to reinit database (rake db:init) to let sidekiq run properly
    rake sidekiq:start

The (very useful) Sidekiq Admin interface currently isn't set up. See [Sidekiq's documentation on standalone installation](https://github.com/mperham/sidekiq/wiki/Monitoring#standalone) for how to enable it.

## Stop sidekiq
    rake sidekiq:kill

## Find missing Indexes
    lol_dba db:find_indexes

## Run analysis of security vulnerabilities
    brakeman

# Troubleshooting

    delete folder vendor/bundle
    bundle install

# Further links & documentation

* [Buzzn API](https://github.com/buzzn/buzzn/blob/master/docs/api.md)
* [NewRelic](https://rpm.newrelic.com/accounts/791323/servers)
* [Data Model](https://www.lucidchart.com/documents/edit/023ef2a3-0b1d-4740-a202-4ad868f3c098)
* [Overview over Groups, Registers, their User's roles and Invitation flow](https://www.lucidchart.com/documents/edit/0a16d140-934c-4f50-b730-7d6684162232/0)
* [Privacy Settings (readability) of Resources](https://docs.google.com/spreadsheets/d/13NtNstj4AVEbxvXTEgx6Hit-g0NHsS7Uy5JPYceETjI/edit#gid=0)
* [All Notifications & their User Groups](https://docs.google.com/spreadsheets/d/1OPsKFke9NGUYPtWs7Nv5Iv4hMAvqpmYvCPtXEhPhYL4/edit#gid=0)
* [Overview over treating notifications on backend side](https://www.lucidchart.com/documents/edit/7f412806-aa84-46d6-93c7-76bedebd47d9)
