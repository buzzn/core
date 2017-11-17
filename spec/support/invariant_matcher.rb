require 'rspec/expectations'
require 'buzzn/schemas/support/enable_dry_validation'

RSpec::Matchers.define :have_valid_invariants do |expected|
  match do |actual|
    actual.invariant.success?
  end

  failure_message do |actual|
    "expected #{actual.class}##{actual.id} to have valid invariants: #{actual.invariant.errors.keys.join(',')}"
  end

  failure_message_when_negated do |actual|
    "expected #{actual.class}##{actual.id} to have valid invariants: #{actual.invariant.errors.keys.join(',')}"
  end
end
