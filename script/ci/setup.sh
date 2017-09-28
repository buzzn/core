#!/usr/bin/env bash

echo "Hello world from setup"

# for using custom mongodb version
curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/mongodb.sh | bash -s
sed -i s/27017/27018/ config/mongoid.yml

# We support all major ruby versions: 1.9.3, 2.0.0, 2.1.x, 2.2.x and JRuby
rvm use `cat .ruby-version` --install
bundle install

# switch postgres version via port config
sed -i "s|5432|5436|" "config/database.yml"

# need special password hash user in DB
createuser -U postgres ${PG_USER}_password