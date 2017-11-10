# How to RSpec #

The general setup is that each file and its containing tests will get a clean database. As the database-cleaner gem does have some difficulties to clean the DB some tables gets deleted manually at the beginning of the running the tests of a file. See [specs/spec_helper.rb]() which migt needs adjustments on which tables to be cleaned.

**Note**: the reason for database-cleaner to fail is that referenced entities are not deleted before the actual and foreign-key constraints prevent the table truncation. might be a problem with our DB schema.

## Buzzn specific DSL extension ##

The use of `let` and `let!` is standard RSpec and Minispec (ruby default test framework). But `let` and `let!` do cache their values for a single test but recreates the object for the next test. To write the tests in way that you can reuse the created entities in the DB is easy and usually needs only a small change. The new DSL methods `entity` and `entity!` work the same way as a `let` and `let!` but keeps the object cached for the complete file.

So far the cleanup failures of the database-cleaner did not pop up with this approach, though the underlying problem persists.

The overall idea to reuse as many objects as possible via `entity` and `let`. in some cases it is needed to flush a cached object, i.e. when testing some deletion of objects: `flush(key)` best embedded in like this:

```
begin
  superdupper.test(code)
ensure
  flush(:superdupper)
end
```

## Directory Structure ##

spec/
├── buzzn # corresponds to lib/buzzn
├── fabricators # all the fabricators for the seeds, can be used by console
|               # and tests as well
├── lib # remaining test which are either broken or slow or need DB cleanup
|       # before each test
├── models # model tests
├── pdfs # tests for pdf generators
├── requests # request tests
├── resources # resources tests
├── services # services tests
├── source_file_spec.rb # pattern check of unwanted coding pattern
├── spec_helper.rb # setup including adding the entity DSL
├── support # support files for rspec
└── vcr_cassettes # vcr cassettes used by some tests

### spec/buzzn

Following the directory layout of gem and using the `Buzzn` namespace for all its classes/modules. It corresponds to /lib/buzzn classes. Ideally each of it has some tests.

### spec/models

Model have an invariant to be tested and the persistence functionality of model. straight forward CRUD need no tests but any scope or extra method needs at least one test.

### spec/permissions

Permissions are a ruby module included into the model providing the `creatable_by?`, `readable_by`, `updatable_by?` and `deletable_by?` methods. *Note* the missing *?* at readable_by which is provided by the `PermissionsBase` module.

Tests for all cases are needed in systematical manner.

### spec/resources

The idea of the resource is to combine a user with model and to offer extended business logic to client/user of the resources. A resource can also function as an output filter.

Tests needs to check the correct type on models/resources with inheritance and each business logic method needs tests. As the resource als defines the attributes seen by the client the expected list of attributes needs tests.

### spec/services

Each service needs a test. Either use the service via `new` and use the injection dependencies or create the service with some test dependencies.

### spec/roda (former spec/request/api/v1)

Each roda can be tested isolated mounting it at the root of the url or using the complete roda tree from `CoreRoda`.

As the roda enpoint actually wraps http around some business logic method the tests will look at each possible status code and its produced json output.

It can happen that the output depends on the users permissions, so all cases needs to be tested. Also endpoints which are 'polymorphic', for example deliver `Meter::Real` or `Meter::Virtual` needs to interate over these types.

As we test the http side of things here each test should look at on status code of one endpoint:

    * GET 200 : retrieve resource as admin and verify json
	* GET 200 all : retrieve collection of resources as admin and verify json
	* POST 201 : create single resource as admin and verify its json
	* POST 201 all : create collection of resources as admin and verify json
	* PATCH 200 : update a resource as admin and verify json
	* DELETE 204 : delete a resource as admin and verify json
	* GET 404 : retrieve resource with unknown ID as admin and as anonymous-user and verify json
	* GET 403 : retrieve resource without permissions as user and as anonymous-user and verify json
	* POST 403 : create resource permissions as user and as anonymous-user and verify json
	* PATCH 404 : update resource with unknown ID as admin and verify json
	* DELETE 404 : delete resource with unknown ID as admin and verify json
	* POST 422 missing : create resource without any params and verify json
	* POST 422 wrong : create resource with all wrong params and verify json
	* PATCH 422 wrong : update resource with all wrong params and verify json

NOTES:

    * admin is easy as s/he always has permissions but any user with enough permissions will do
	* on public resource 403 is not possible
	* some resources do not have such fine grained permissions, i.e. can read parent (localpool but can not create billings). if such user exists then it woule make sense to use this user. otherwise skip the tests as we check the retrieval of the parent resource and its permission already in the test of the parent roda
	* small tests vs longer ones: whenever a tests does too much and fails early the rest of the test gets skipped. this hides the further problems. as we share resources splitting a long test into two usually means two line of code: ```end
	it 'next test' do```
	* ideally the roda tree should have one roda-class per resource which works nice with crud
	* roda-classes can be polymorphic in the sense one roda-class can be mounted at more then one parent. example: ReadingRoda can be mouted under 'register/real/readings' as well under `register/virtual/readings' or under 'registers/reading'. the ReadingRoda needs to be tested against both real and virtual registers but mounting is the responsibility of the parent. dito with bank_accounts, addresses

### spec/transactions

As transactions provide some business logic as single object (with a `call` method). A typical transaction consists of two steps:

    * validate and coerce the input parameters
	* create/update/delete action on a resource

other transaction are possible like the charts/bubbles/tickers or groups/registers.

Usually it is sufficient to test a transaction via the roda tree using it. some more complex validation need systematic tests and will be put here.

### spec/pdfs

Each PDF-template needs a tests which takes seeded data and produces the html intermediate result and verify that the conversion of html to pdf produces a pdf. The html is best compared with complete stored file, the PDF endresult it is sufficient to check first few bytes to ensure it has the PDF prolog.
