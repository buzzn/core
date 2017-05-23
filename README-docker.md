# Docker
please install docker.
https://docs.docker.com/docker-for-mac/install/

- build core(aka buzzn) image `docker-compose build`
- init database for development `docker-compose run core rake db:init`
- start cluster `docker-compose up` stop with control-c
- remove cluster `docker-compose down`
- run specs from outside `docker-compose run core rake specs`

#### More infos about:
- production: https://blog.codeship.com/deploying-docker-rails-app/
- Dev/Test: https://blog.codeship.com/running-rails-development-environment-docker
- Assets https://blog.red-badger.com/blog/2016/06/22/docker-and-assets-and-rails-oh-my
