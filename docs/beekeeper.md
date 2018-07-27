# Beekeeper

## import data

first convert the mysql into postgres and load them into postgres


```
FILE=/sync/minipoolsq.sql rake beekeeper:sql:mysql2postgres
FILE=/sync/buzzndb.zip rake beekeeper:sql:mysql2postgres

```

note that both zip and sql can be used.


second make sure the actual import

```
bin/beekeeper
```
is running.

## deploy on staging

first make sure you have following variabltes defined in your .env.staging

```
AWS\_ACCESS\_KEY=....
AWS\_SECRET\_KEY=....
AWS\_REGION=eu-west-1

AWS\_BUCKET=buzzn-core-staging
ASSET\_HOST=https://staging-files.buzzn.io
```

then run the actual update

```
rake heroku:update_db:staging
```

sometimes it is neccesary to restart the application as the DB schema might have changed and active-record caches the columns-info per table.

```
heroku ps:restart --remote staging
```
