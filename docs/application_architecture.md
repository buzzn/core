# buzzn architecture

Note: as with most systems, the buzzn/core architecture is not perfectly consistent. 
What is described here how we implement new features. Legacy code is converted when functional changes require it, and when the time allows it.

### Brief overview of the typical request flow

Example: updating a register.

- the requests is routed to a block of code through in the roda tree (in lib/roda). Roda code blocks are comparable to Rails controller actions. So the responsibilities of that block are
    - authorization
    - calling the business logic
    - TODO
- Buzzn::Transaction encapsulates the business logic. It is optional, sometimes it's enough to just implement a Buzzn::Resource (lib/buzzn/transactions).
- Buzzn::Resource (lib/buzzn/transactions)
    - handles authorization / permissions
    - can implement business logic
    - serializes response to JSON

### How & where do we validate stuff?

We distinguish between these types of validations

- "high-level", context-specific validations (on update of a user an id must be submitted). Used to validate requests. They are implmented with dry-validations found in lib/schemas, lib/validation ?
- record invariants (user must always have a first name). Currently implemented with the validate_invariants method in each ActiveRecord model
- TODO

### How do we use ActiveRecord?

We use the ORM features of ActiveRecord, but don't put business logic there. So scopes, associations and finders are Ok to use. Regarding other AR features:

* lifecycle callbacks (before_create, ...) 

We use them when they only affect the record itself. They should not affect other objects, send emails, generate queue messages, or have other unexpected side-effects. Those things should instead happen on a higher architectur layer, i.e. in the resource or transaction.

* validations

- deprecated
- see the validations section on this page for how to do things instead.

### What about Rails?

The Rails framework does (a lot of useful things)[https://github.com/rails-api/rails-api#handled-at-the-middleware-layer], but some of that we want do to differently. Details:

- we don't use controllers, they are replaced by the Roda tree.
- we don't use views and the asset pipeline, they are in the process of being removed. Check branch remove-assets for current status.
- the Rails logging mechanism will be replaced by our own logging (Buzzn::Logger)
- Rails environments will be discontinued. The application will configuration only through environment variables. See http://12factor.net/config for the reasoning
- tests: the tests inherit from Rack::Test
- mid-term the rails gem should be removed, and replaced with the gems we still want to use (like activerecord, activesupport, rack, rack-test, bundler)