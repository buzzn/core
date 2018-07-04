# directory structure

## lib/beekeeper

import code from old beekeeper to buzzn.net

## lib/tasks

rake tasks

## lib/buzzz

```
lib/buzzn
├── boot            # start up of the containers, logger, etc
├── builders        # any kind of builders or factories
│   ├── billing
│   └── discovergy
├── core            # obsolete
├── crypto          # some crypto stuff
├── localpool       # obsolete
├── operations      # these are functions used by transactions - instance stored in container
│   ├── action
│   └── authorization
├── permissions     # per application permissions
│   ├── admin       # for admin-app
│   └── display     # for display-app
├── resource        # framework for resources with security-context
├── resources       # resources per application, defines the json format
│   ├── admin       # for the admin-app
│   ├── contract    # common contract
│   ├── display     # for the display-app
│   ├── meter       # common meter
│   └── register    # common register
├── roda            # roda-tree per app
│   ├── admin       # for admin-app
│   ├── display     # for display-app
│   ├── helpers     # helpers used by roda controllers
│   ├── me          # common me, login and user profile, etc
│   ├── plugins     # custom roda-plugins
│   └── utils       # utils-app which is used by websites
├── schemas         # all based on dry-validation
│   ├── completeness # per application: `completeness` attribute on resource
│   │   └── admin    # for admin-app
│   ├── constraints  # constraints are basic required/optional + type on model
│   │   ├── contract
│   │   ├── meter
│   │   ├── reading
│   │   └── register
│   ├── invariants   # high level rules on model or model graph
│   │   ├── contract
│   │   ├── group
│   │   ├── meter
│   │   └── register
│   ├── pre_conditions # precondition on model-graph for certain actions
│   │   └── contract
│   ├── support      # predicates, error messages, etc used by schemas
│   └── transactions # input params validation for a given transaction
│       ├── address  # common address
│       ├── admin    # for admin-app
│       │   ├── billing
│       │   ├── billing_cycle
│       │   ├── localpool
│       │   ├── meter
│       │   ├── reading
│       │   ├── register
│       │   └── tariff
│       ├── bank_account
│       ├── display  # for display-app
│       ├── me       # for me-app
│       ├── organization
│       ├── person
│       └── utils    # for utils-app
├── security
├── services         # instance stored in container
│   └── datasource
│       ├── discovergy
│       └── standard_profile
├── transactions     # business transaction per application
│   ├── admin        # for admin-app
│   │   ├── bank_account
│   │   ├── billing
│   │   ├── billing_cycle
│   │   ├── localpool
│   │   ├── meter
│   │   ├── reading
│   │   ├── register
│   │   └── tariff
│   ├── display      # for display-app
│   ├── person       # common
│   ├── step_adapters # custom step-adapters for the dry-transactions used
│   └── utils        # for the utils-app
├── types            # data types using dry-types, dry-initializers, etc
│   ├── datasource
│   └── discovergy
└── utils            # utils stuff
```

## app

```
app
├── models       # active-record models
│   ├── account
│   ├── broker
│   ├── concerns
│   ├── contract
│   ├── group
│   ├── meter
│   ├── reading
│   └── register
├── pdfs        # slim templates and binding class for pdf generation
├── mails       # slim templates and binding class for mail generation
└── uploaders   # image uploaders
```

## db

```
db
├── banks         # files from Bundesbank to be imported
├── csv           # zip-to-price mapping data
├── example_data  # data used to seed development environment
│   └── person_images
├── factories     # used by tests and by example_data
├── migrate       # AR migrations
├── sequel        # sequel migrations (for all the app/models/account/* models)
├── setup_data    # setup-data used by example_data and tests
│   └── csv
└── support       # helper code
```

## config

```
config           # boot code and config files
└── initializers # setup external libraries
```

## root: /

### project files

* Gemfile      # library depdenencies descriptor (bundler)
* Gemfile.lock # bundler lock-file
* Guardfile    # if you want to use Guard
* Procfile     # for heroku
* Rakefile     # entry to all rake tasks
* config.ru    # rack-up file to start the server

### configurations

* .env             # common configuration
* .env.development # for the development server
* .env.local       # not track by git, i.e. passwords, etc
* .env.test        # for running tests
