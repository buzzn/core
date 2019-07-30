RSpec::Matchers.define :transaction_result do |*attrs|

  matcher :be_success do
    match { |actual| actual.is_a?(Dry::Monads::Either::Success) }
  end

  matcher :be_failure do
    match { |actual| actual.is_a?(Dry::Monads::Either::Failure) }
  end

end
