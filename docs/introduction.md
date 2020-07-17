# The platform’s history

At the beginning there was Excel. But people understood that this was no good tool to do power business with. Then the beekeeper was written. It was a database frontend to get and insert data where the user had to know what to enter. It had no consistency checks available and everything was dark in the database. But it had many features, a word integration and mass mail sending, which helped the user a lot!
 
Then buzzn started creating the Platform. The Platform’s idea was to enable every person to run or participate in the local power distribution business without much knowledge about the energy market. It was done in Ruby on Rails using the Rails controllers and templating system. But the database of beekeeper was in such a poor state, that it was not being useful anymore. So the decision was made to create a completely new system. The core repository which was forked from the previous rails project.

The core has dependencies to rails, but they are meant to be removed and can be exchanged. Now the project was split into a backend and a frontend. Where the frontend was an independent project. The migration from the beekeeper database was its own project. A script was written that tried to make sense of the beekeepers database and inserted it into the core’s database.

# Tech stack
The core is a ruby (not rails) application using ruby dry, roda, rodauth, postgresql and some more technologies.

There are three databases:
* A postgres for the storage of the data to work on.
* A redis database to store the work to do for the sidekiq such as mailing documents.
* There is another redis cache (simply key value store for e.g. meter readings)

The platform itself is built as a monolith with some small services hosted at heroku. As an ORM system ActiveRecord is used which is well documented by the rails project. The management of the http api roda is used as a router. The idea was to wrap each request into a transaction.

The frontend is a React+Redux application. Hosted in an amazon bucket for no specific reason. In general it lacks the ux perspective of different user roles: It looks the same whether you are an admin or a user with very limited rights.

The communication from frontend to backend is over a public available REST api using something which looks like Graphql, since Graphql was not around yet/very young. This was a custom development.

# Edifact messaging
An Edifact message is an archaic message format to send request to other market players. It is encrypted and signed, so a list of certificates needs to be maintained. In order to run a power business, buzzn needs to be able to send edifact messages to communicate about the power it is producing or consuming. This is done by a bunch of php and bash scripts which are run continuously by some cron jobs. The scripts use many regex expressions to craft the massages and deliver them to the other market participants.

But sometimes buzzn needs to send custom edifact messages to energy suppliers. This is done by Fernschreiber a tool to deliver custom edifact messages to others. It has a folder with all the certificates of the market players buzzn wants to talk to. Every time one of them changes its certificat it needs to be updated in the fernschreiber folder too. 

# App
The most recent product developed by buzzn. The frontend is written in VueJS and the backend in Flask with an Sqlite database. It is delayed at the time, because the platform core is more important.

# Summary
Buzzn’s system infrastructure is defragmented. Technology was chosen either in a very idealistic approach or in a rush where no capacity was available to do anything but follow the most pragmatic path. Each service runs on another server at another provider, thus the communication between the services is done via public internet. Buzzn hadn’t had the resources to maintain a canonical server infrastructure which enables buzzn to implement a proper communication model with security aspects in mind.

# The platform from an technical perspective
The app folder contains the models, the state machines and templates to generate the pdf documents. The db directory contains all the migrations to get the database structure up to date to the according version.
The config directory sets up database, sideqik, puma. /config/boot.rb and /config/buzzn.rb contain the entry points into the application.
The lib directory contains all the business logic.
The lib/buzzn/services contains the services used by buzzn for example receiving or inserting data into the redis cache.
The testdata is injected into the test database and byepass the transactions which would create them thus it is possible to or likely to setup a unitest which works on inconsistent data.
The lib/buzzn/boot sets up the services and registers the config stuff. 

# Roda - the routing framework
Roda is a routing framework that allows to create independent roda components for each level. This way the different roda components can be reused in different contexts. Say there are the paths `/foo` and `/bar` where both `foo` and `bar` are each an entity. Both entities can be created calling `/foo/create` and `/bar/create`. Roda allows to create a generic `create component` which can be reused in `/foo/create` and `/bar/create`.

Each level manches by a roda is called a RodaComponent. As said, RodaComponents can be composed into a tree. One RodaComponent runs another. If the path is `/foo/1/do-something` the `/foo/1` can be handled by one RodaComponent and `/do-something`

# Transactions
See [dry-transactions](http://dry-rb.org/gems/dry-transactions)
Transaction - typical steps are:
* validate incoming params
* authorize the action
* precondition check if needed, i.e. can we already create the contract ?
* time consuming operations, i.e. network access (Discovergy) or pdf generation
* start DB transaction with `around db_transaction`. from here onward all steps are 

In this application all transactions use KWARGS to simplify the input/output of the steps and get some method arguments control. There are couple of custom steps used.

All transaction will inherit from `Transaction::Base` (`lib/buzzn/transaction/base`) and this gives you the around `db_transaction`. All our transactions are singletons and will be inject into a roda controller.

## validate step (custom)

its operation method returns a schema which is used to validate the `params` kwarg.
```ruby
validate :my_schema

def my_schema
  Schemas::Transactions::Admin::Contract::MeteringPointOperator::Create
end
```
if validation succeeds then the output is the given input.

## authorize step (custom)

Its operation method returns a list of allowed roles. It gets the `permission_context` passed in which is basically `resource.security_context.permissions`. on this object you must get the allowed roles for the action the whole transaction is performing. example to create a new contract:

```ruby
authorize :roles

def roles(permission_context:)
  permission_context.metering_point_operator_contract.create
end
```
if authorization succeeds then the output is the given input.

## precondition step (custom)

This is similar to the validate step but schema validation acts on the `resource`.
```
precondition :schema

def schema
  Schemas::PreConditions::Contract::MeteringPointOperatorCreate
end
```
and again if validation succeeds then the output is the given input.

## add step (custom)

Here the output of the operation action is added to the input kwargs using the name of the operation as key.

This comes handy if you want to attach some output to the kwarg for later use. i.e. create a PDF and use it later in the transaction
```ruby
add :pdf
# more steps here
map :last

def pdf(resource:)
  Generator.create_pdf(resource)
end

def last(pdf:)
  pdf
end
tee step (default)
```

Just perform some side tasks and passes the input on as output.

## check step (default)

If the operation method returns `true` then the input gets passed on as output. otherwise a `Failure` is returned. Currently this is used with operation which raise errors, i.e. `tee` could be used in the same manner.

## map step (default)

Just wrappes the result of the operation method in a `Success`. usually used as last step to drop the kwargs and produce the final resource.

## Operations
All operations are singletons and used when you want to share functionality between transactions or you need to inject other object. Transactions have a non trivial constructor so injection is better done on Operations. These are a simple PORO.

## Validations
There are different types of validations depending on what level should be checked. The user input or the data available.
## Schemas
This work on the user input. It can be used to check whether the the parameters are correct and have the right format.
## Pre Conditions
This checks run on the resources being worked on. They can be used to check if some data is available. 
## Constraints
Constraints are the same as Schemas, except they are used migrations to create the database schema. Constraints are deprecated, but can't be replaced by schemas because they are needed to run the migrations. So we need to keep them as a legacy.
## Permissions
Permissions are usually handled `/lib/buzzn/admin/permissions.rb`. But they have not been tested yet for consistency and should be double checked.
## Invariants
Invariants are post conditions which are checked at the very end and says if the transaction’s outcome is valid. 

# Model vs Resources
The model represents all the data as it is stored in the database, a resource represents the model how it should be exposed to the user.

# How billing is done in the platform
The most important Model is the Group object. This is what the local power business and the platform are all about: Groups contain a power giver and a set of power takers consuming the energy. A group is either owned by an organization or a person. There was an effort to keep the Group model simple and prevent the rise of an GOD-Object. However many entities have been created which are connected as a 1:1 relationship with the Group. 

# Contract
A contract describes the role of the contractor in the Group which can be for example power giver and power takers. Contracts within a Group share the same prefix Contract number and an individual suffix after a slash. Say the contract number is 60020/1 then the 60020 is the common prefix and the 1 is the individual suffix where other group members have 60020/2, 60020/3, 60020/4…
# Register Meta
These are the entities powered or producing electricity which can be flats or houses.  Usually there are power consumers behind a register meta which shall be billed all together. One person wants a billing for all his consumers but not for the neighbour ones. Or the common one like the lights in the shared property like the doorway. 

# Meters and Registers
A meter is an energy amount counting device. A physical device screwed at the walls. A meter can hold a set of registers which do the actual energy counting. A register can just count in one direction usually one kind of power per wire. If there are more than one wire/phase there are more registers for the additional phases needed. If active, reactive, and apparent power are to be measured as well, you end up with a total of three registers per phase.
# Readings
Readings are the amount of energy consumed or produced at a certain point in time. Each reading has a specific reason, for example the payday came and to create the billing the amount of consumed energy needs to be taken into account. Then a reading is created and for the end date of the billing period and as reason the billing-reason is given. 
# Tariffs
A tariff defines the price for energy in a certain amount of time and a group. Usually is provided by the power giver, because he knows how much his power costs and how much money he wants to make. Tarrifs can not overlapp, this is usually done by a startdate. So if another tariff comes into play, the previous ends when the new tariff starts.
# Billing
A billing consists of begin date end date, invoice number and status. Status is either open, calculated, documented, queued, delivered, settled, closed, and void. Open means that a billing is about to be created, the user gives his intention to create a billing. There still can be data missing like the readings for the meters. Calculated means that all data is available and the numbers are fixed. Documented means that documents have been created, the pdf to be specific. Queued means the billing is up to be sent to the user, but the mail has not yet left the server. Delivered means that the email is out. Settled means it is paid. Void means that the billing has been canceled during the process. Void is important because there can not be two billing overlapping the same time period, so if there is something wrong with some billing there needs to be a way to dismiss it. This is the void status.
# Billing items
A billing item is the amount of money which has to be paid for one register, for one tariff within a specific time period. This means if a meter for one flat has several registers the billing will contain several billing items.  For a billing item there needs to be the readings available for begin and end of the time period.

When a billing is created in a period (begin_date -> last_date), BillingItems will be created in the regions where no other BillingItems exist yet. In the most simple case you will end up with one BillingItem per Billing.
However if there is a change of any associated entity in the range more BillingItems might be created.
Currently these cases are possible:
* A Meter was changed for the RegisterMeta, so we will have two BillingItems, one for the first meter until it was removed, then a second BillingItem for the new Meter, starting with the install date. The removal reading is marked by reason COM1, the installment of the new by reason COM2.
* A tariff change occurred, so the part of the Billing must be billed with Tariff1, part with Tariff2, part with TariffN
* Another BillingItem is already present, so it needs to be sandwiched by two
* (NOT IMPLEMENTED AS OF 2020/07/15) a VAT change has occurred

# begin_date, last_date and end_date 
There is an important convention for naming date ranges for all sorts of entities like contracts, billings, tariffs etc.

* begin_date: beginning of the range
* last_date: last day of the range
* end_date: one day after last_date, when the entity is not active anymore

## Example:
You move into an apartment, your contract starts on the 1.1., this your begin_date
You decide to move out in end of August, so your last_date will be the 31.8.
One day after the 31.8. Is the 1.9. - this is the end_date of your contract - basically the day that is one second after 31.8 23:59h.

The person who moves in after you on has the begin_date 1.9.
Your landlord (this would be the powergiver or buzzn) can easily verify that there is no day where the apartment is not occupied by comparing begin_date and end_date, which is here `1.9 == 1.9`.

# Gap contracts and gap tariffs
When a market location is empty, gap contracts and gap tariffs come into play. This can occur when for example a flat is empty, the renter has moved out and the owner wants to renovate before someone moves in again. Then a gap contract with a gap tariff applies for this time period where the contractor is usually the flat’s owner.

# Third party contracts
Due to legal issues, there needs to be a possibility allowing power takers to get energy from third party energy providers. 