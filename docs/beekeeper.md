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


```
rake heroku:update_db:staging
```
