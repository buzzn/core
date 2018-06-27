# How To create new Endpoint

## low level: model

* add model into ./app/models
* add migration in ./db/migrate
* nice to have a factory in ./db/factories with tests in ./specs/factories/factories_spec.rb
* remember to run migration once to update ./db/structure.sql

## business transaction

* add permissions at the place in the resource graph
* add resource object to define the json response
* each transaction usually uses some input validation which are all located under lib/buzzn/schemas/transactions/
* adds transactions for any action like: create, update, delete

typical directory layout
```
lib/buzzn/schemas/transactions/
├── device
│   ├── create.rb
│   └── update.rb
lib/buzzn/transactions/admin
├── device
│   ├── create.rb
│   ├── delete.rb
│   └── update.rb
```
