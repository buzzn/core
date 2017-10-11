# buzzn architecture

Note: as with most systems, the buzzn/core architecture is not perfectly consistent. 
What is described here how we implement new features. Legacy code is converted when functional changes require it, and when the time allows it.

### Brief overview of the typical request flow

Example: updating a register.

- the requests is routed to a block of code through the roda tree (in lib/roda). Roda code blocks are comparable to Rails controller actions. So the responsibilities of that block are
    - authentication
    - request validation
    - calling the business logic
    - producing the HTTP response (headers, status, ...)
- Buzzn::Transaction (lib/buzzn/transactions) encapsulates the business logic. It is used for mutating resources. Reads go directly to a Buzzn::Resource.
- Buzzn::Resource (lib/buzzn/transactions)
    - handles authorization / permissions
    - can implement business logic
    - serializes response to JSON

### How & where do we validate stuff?

We use [dry-validation](http://dry-rb.org/gems/dry-validation) schemas for all new validations ("schemas"). They are used on these levels:

#### 1. Completeness schemas

In some parts of the application we want to show users that an object graph is not yet complete. The completeness schema validates that. For example, while a customer can be saved without a bank account, the bank account is required before the billing can be started.

#### 2. Transaction schemas

Transaction schemas validate the client request data before it is passed to the transaction.
Depending on the kind request and transaction ("context"), data for the same model may have to be validated differently.

#### 3. Invariants schemas

These are model-layer validations that always must be true, regardless of context. A user record must always have a first and last name, a register must always have a meter, and so on.

We define these invariant validations in separate schemas and generate database constraints for the model from them.

Note on the ActiveRecord validations: the standard validation DSL (`validates :iban, presence: true`, etc.) as well as the methods `validate_invariants` are deprecated. We're in the process of replacing them with invariant schemas.

### How do we use ActiveRecord?

We use the ORM features of ActiveRecord, but don't put business logic there. So scopes, associations and finders are Ok to use. Regarding other AR features:

* lifecycle callbacks (before_create, ...) 

We use them only to change the record itself. They should not affect other objects, send emails, generate queue messages, or have other unexpected side-effects. Those things should instead happen on a higher architectur layer, i.e. in the resource or transaction.

* validations

- deprecated
- see the validations section on this page for how to do them instead.

### What about Rails?

The Rails framework does [a lot of useful things](https://github.com/rails-api/rails-api#handled-at-the-middleware-layer), but some of that we want do to differently. Details:

- we don't use controllers, they are replaced by the Roda tree.
- we don't use views and the asset pipeline, they are in the process of being removed. Check branch remove-assets for current status.
- the Rails logging mechanism will be replaced by our own logging (Buzzn::Logger)
- Rails environments will be discontinued. The application will only be configured through environment variables. See http://12factor.net/config for the reasoning.
- tests: the tests inherit from Rack::Test
- mid-term the rails gem should be removed, and replaced with the gems we still want to use (like activerecord, activesupport, rack, rack-test, bundler)