# buzzn architecture

Note: as with most systems, the buzzn/core architecture is not perfectly consistent. 
What is described here how we implement new features. Legacy code is converted when functional changes require it, and when the time allows it.

### Brief overview of the typical request flow

Example: updating a register.

- the requests is routed to a block of code through in the roda tree (in lib/roda). Roda code blocks are comparable to Rails controller actions. So the responsibilities of that block are
    - authentication
    - request validation
    - calling the business logic
    - producing HTTP response (headers, status, ...)
- Buzzn::Transaction (lib/buzzn/transactions) encapsulates the business logic. It is used for mutating resources. Reads go diretly to a Buzzn::Resource.
- Buzzn::Resource (lib/buzzn/transactions)
    - handles authorization / permissions
    - can implement business logic
    - serializes response to JSON

### How & where do we validate stuff?

Validation levels

1. incompleteness 
    - dry validation
    - 

2. transaction validations (validate the requests)
    - dry validation
    - in buzzn/schemas

3. invariants (on the model)
    - use validation for create transaction to generate DB constraints
    - method validate_invariants (AR validations/errors) (deprecated)

### How do we use ActiveRecord?

We use the ORM features of ActiveRecord, but don't put business logic there. So scopes, associations and finders are Ok to use. Regarding other AR features:

* lifecycle callbacks (before_create, ...) 

We use them only to change the record itself. They should not affect other objects, send emails, generate queue messages, or have other unexpected side-effects. Those things should instead happen on a higher architectur layer, i.e. in the resource or transaction.

* validations

- deprecated
- see the validations section on this page for how to do them instead.

### What about Rails?

The Rails framework does (a lot of useful things)[https://github.com/rails-api/rails-api#handled-at-the-middleware-layer], but some of that we want do to differently. Details:

- we don't use controllers, they are replaced by the Roda tree.
- we don't use views and the asset pipeline, they are in the process of being removed. Check branch remove-assets for current status.
- the Rails logging mechanism will be replaced by our own logging (Buzzn::Logger)
- Rails environments will be discontinued. The application will only be configured through environment variables. See http://12factor.net/config for the reasoning.
- tests: the tests inherit from Rack::Test
- mid-term the rails gem should be removed, and replaced with the gems we still want to use (like activerecord, activesupport, rack, rack-test, bundler)