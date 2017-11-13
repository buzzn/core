# Using Docker for local development

#### Quick overview

- the file [docker-compose.yml](./docker-compose.yml) describes the stack, i.e. the Rails application and all services it requires (postgresql, mongodb, redis) **for local development**.
- after the [initial setup](#initial-setup), start the stack with `docker-compose up`
- stop it with `Control-C` in the same or `docker-compose down` in a separate shell.
- the stack is running Rails in the **development** environment (controlled by [.env](./.env) and [.env.development](./.env.development))
- the root directory of this git repository is mounted into the docker container. That means file changes are immediately effective in the docker container.

#### How to deploy

Deployment is the business of the [buzzn/devops](https://github.com/buzzn/devops) repository. The `docker-compose.yml` file in this repo is **irrellevant for deployment**, env variables set in here will likely be ignored or overridden! See [buzzn/devop's README-DOCKER](https://github.com/buzzn/devops/blob/master/README-DOCKER.md) for more info.

# Initial setup

Before running the stack with docker for the first time, run these commands:

- start all containers required for the stack:
    - `docker-compose up`

- from a separate shell, initialize the application:
    - `docker exec core_web_1 rake application:init`

- additionally run the following to load some example data:
    - `docker exec core_web_1 rake db:empty db:seed:example_data`

# Day to day development

#### Running tests

`docker exec -e RAILS_ENV=test core_web_1 rspec`

#### Run tests constantly with guard

`docker exec -e RAILS_ENV=test core_web_1 guard`

Note: right now guard doesn't work properly, it doesn't start on file changes. Whether running the app in docker or on "bare metal".

#### Open a shell in the Rails/web container

`docker exec -it core_web_1 /bin/bash`


#### Rebuild container after changes

Run `docker-compose up --build`. That is usually only required when changing the `Gemfile` or the `Dockerfile`.

#### Starting the sidekiq worker

This starts the worker inside the Rails application container:

`docker exec -it core_web_1 bundle exec sidekiq`

#### Starting clockwork (cron replacement)

This starts the worker inside the Rails application container:

`docker exec -it core_web_1 bundle exec clockwork config/clock.rb`

#### Create Release Image

- the fast way:
  - `rake docker:image:push`. This image is then addressable in docker hub as `buzzn/core:latest`.

- the manual way, with more control and tagging the created image:
  - login to dockerhub `docker login -u=buzzn -p=xxxxxx`
  - build image `docker build -t buzzn/core .`
  - tag image `docker tag buzzn/core buzzn/core:6`
  - push image `docker push buzzn/core:6`

# Troubleshooting

Some useful commands:

- list all containers of the stack `docker-compose ps`
- stop the stack `docker-compose down`
- remove all volumes to delete the databases:
  - make sure to turn off all containers accessing the volumes: `docker-compose down`
  - run `docker volume prune`
- remove all buzzn containers `docker rm -f $(docker ps -a -q -f name=buzzn)`
- remove all buzzn images `docker rmi -f $(docker images buzzn* -q)`

#### More infos about

- production: https://blog.codeship.com/deploying-docker-rails-app/
- Dev/Test: https://blog.codeship.com/running-rails-development-environment-docker
- Assets https://blog.red-badger.com/blog/2016/06/22/docker-and-assets-and-rails-oh-my
