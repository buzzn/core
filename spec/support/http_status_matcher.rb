require 'rspec/expectations'

RSpec::Matchers.define :have_http_status do |expected|
  match do |actual|
    actual.status == expected
  end

  failure_message do |actual|
    "expected #{expected} but received #{actual.status}"
  end

  failure_message_when_negated do |actual|
    "did not expect #{expected}"
  end
end
