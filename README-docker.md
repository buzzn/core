# Docker
please install docker.
https://docs.docker.com/docker-for-mac/install/

#### setup
the `docker-compose.yml` describes the stack.
the default stack is running the staging environment.
but you can also uncomment the core_test service for running your tests.

- start cluster `docker-compose up` stop control-c.

#### Create Release Image
- login to dockerhub `docker login -u=buzzn -p=xxxxxx`
- build image `docker build -t buzzn/core .`
- tag image `docker tag buzzn/core buzzn/core:6`
- push image `docker push buzzn/core:6`

#### troubleshoot
- stop the stack `docker-compose down`
- remove all volumes  `docker volume prune`
- remove all containers `docker rm -f $(docker ps -a -q)`
- remove all image `docker rmi -f $(docker images -q)`
- rebuild image `docker-compose build`

#### More infos about:
- production: https://blog.codeship.com/deploying-docker-rails-app/
- Dev/Test: https://blog.codeship.com/running-rails-development-environment-docker
- Assets https://blog.red-badger.com/blog/2016/06/22/docker-and-assets-and-rails-oh-my
