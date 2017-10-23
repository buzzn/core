require 'rspec/expectations'

RSpec::Matchers.define :have_valid_invariants do |expected|
  match do |actual|
    actual.invariants.success?
  end

  failure_message do |actual|
    "expected that #{actual.class}##{actual.id} has valid invariants"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual.class}##{actual.id} has invalid invariants"
  end
end
