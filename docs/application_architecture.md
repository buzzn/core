# buzzn architecture

Note: as with most systems, the buzzn/core architecture is not perfectly consistent.
Here we describe how we implement new features. Legacy code is converted when functional changes require it, and when time allows.

### Overview of the typical request flow

Example: updating a register.

- the requests is routed to a block of code through the roda tree (in lib/roda). Roda code blocks are comparable to Rails controller actions. So the responsibilities of that block are
    - authentication
    - request validation
    - calling the bussiness logic
    - producing the HTTP response (headers, status, ...)
- Buzzn::Transaction (lib/buzzn/transactions) encapsulates the business logic. It is used for mutating resources. Reads go directly to a Buzzn::Resource.
- Buzzn::Resource (lib/buzzn/resources)
    - handles authorization / permissions for nested resources and on retrieves
    - can implement simple business logic
    - serializes response to JSON

### How & where do we validate stuff?

We use [dry-validation](http://dry-rb.org/gems/dry-validation) for all new validations ("schemas"). They are used on these levels:

#### 1. Completeness schemas

For some use cases, we want to allow users to save incomplete objects or object graphs. The completeness schema implements the completeness part. Examples:
- while a customer can be saved without a bank account, the bank account is required before the billing can be started.
- when a contract is first created in the system, some information is still not available. We must be able to tell the user which information is still missing.

#### 2. Transaction schemas

Transaction schemas validate the client request data before it is passed to the transaction.
Depending on the kind of request and transaction (create, update, ...), data for the same resource or model may have to be validated differently, so one resource can have several transaction schemas.

#### 3. Invariants schemas

These are model-layer validations that always must be true, regardless of transaction. Examples: a user record must always have a first and last name, a register must always have a meter.

Invariants extend the constraints schemas.

#### 4. Constraints schemas

These are schemas which we use use to create database constraints.

Note on the ActiveRecord validations: the standard validation DSL (`validates :iban, presence: true`, etc.) as well as the methods `validate_invariants` are deprecated. We're in the process of replacing them with invariant schemas implemented with dry-validation.

### How do we use ActiveRecord?

We use the ORM features of ActiveRecord, but don't put business logic in them. So scopes, associations and finders are Ok to use. Regarding other AR features:

#### Lifecycle callbacks (before_create, ...)

We use them only to change the record itself. They should not affect other objects, send emails, generate queue messages, or have other unexpected side-effects. Those things should instead happen on a higher architecture layer, i.e. in the resource or transaction.

#### Validations

Are deprecated, see the validations section on this page for how to do them instead.

### What about Rails?

At the time of writing Rails is a legacy dependency and almost removed. Details:

- currently Rails is only needed because we still have some gem dependencies to it, like rspec-rails, money-rails, dotenv-rails. The Rails dependencies we'll continue to use (activerecord, activesupport, rack, rack-test, bundler, ...) will then become direct dependencies
- instead of Rails controllers, we use Roda tree procs.
- instead of ActiveRecord validations, we use dry-schema; see "How & where do we validate stuff?" for details.
- instead of the views and the asset pipeline, we use the homemade `Buzzn::Resource::*` objects to render the JSON (the application is API-only).
- instead of the Rails logger, we use `Buzzn::Logger`.
- Rails environments are deprecated. The application should only be configured through environment variables. See http://12factor.net/config for the reasoning.
- tests: the tests inherit from Rack::Test.
- the `rails server` and `rails console` tasks have been replaced by `bin/server` and `bin/console`.
