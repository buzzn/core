# Business Transactions

see [dry-transactions](http://dry-rb.org/gems/dry-transactions)

## Context and Overview

API requests take following path through the system:

* Rack - low level request/response handling
* Roda - path and http method matching, it walks the resource graph in the same manner as path.
  * GET request are delegated to the Resource
  * POST/PATCH/DELETE request are delegated to Transaction
* Transaction - typical steps are:
  * validate incoming params
  * authorize the action
  * precondition check if needed, i.e. can we already create the contract ?
  * time consuming operations, i.e. network access (Discovergy) or pdf generation
  * start DB transaction with `around db_transaction`. from here onward all steps are wrapped inside a DB transaction
  * ...
  * create a Resource object - its to_json method is used to create the json http response

## Transactions

In this application all transactions use KWARGS to simplify the input/output of the steps and get some method arguments control. There a couple of custom steps used.

All transaction will inherit from Transaction::Base (lib/buzzn/transaction/base) and this gives you the

```
around db_transaction
```

All our transactions are singletons and will be inject into a roda controller.

```
class LocalpoolRoda < BaseRoda

  include Import.args[:env, 'transactions.admin.localpool.create']

  ...

end

```

### validate step (custom)

its operation method returns a schema which is used to validate the `params` kwarg.

```
validate :my_schema

def my_schema
  Schemas::Transactions::Admin::Contract::MeteringPointOperator::Create
end
```

if validation succeeds then the output is the given input.

## authorize step (custom)

its operation method returns a list of allowed roles. it gets the `permission_context` passed in which is basically `resource.security_context.permissions`. on this object you must get the allowed roles for the action the whole transaction is performing. example to create a new contract:

```
authorize :roles

def roles(permission_context:)
  permission_context.metering_point_operator_contract.create
end
```

if authorization succeeds then the output is the given input.

## precondition step (custom)

this is similar to the validate step but schema validation acts on the `resource`.

```
precondition :schema

def schema
  Schemas::PreConditions::Contract::MeteringPointOperatorCreate
end
```

and again if validation succeeds then the output is the given input.

## add step (custom)

here the output of the operation action is added to the input kwargs using the name of the operation as key.

this comes handy if you want to attach some output to the kwarg for later use. i.e. create a PDF and use it later in the transaction

```
add :pdf
# more steps here
map :last

def pdf(resource:)
  Generator.create_pdf(resource)
end

def last(pdf:)
  pdf
end
```

## tee step (default)

Just perform some side tasks and passes the input on as output.

## check step (default)

if the operation method returns `true` then the input gets passed on as output. otherwise a `Failure` is returned.

currently this is used with operation which raise errors, i.e. `tee` could be used in the same manner.

## map step (default)

just wrappes the result of the operation method in a `Success`. usually used as last step to drop the kwargs and produce the final resource.

## Operations

All operations are singletons and used when you want to share functionality between transactions or you need to inject other object. Transactions have a non trivial constructor so injection is better done on Operations. These are a simple PORO.
