RSpec::Matchers.define :transaction_result do |*attrs|

  matcher :be_success do
    match { |actual| actual.is_a?(Dry::Monads::Either::Right) }
  end

  matcher :be_error do
    match { |actual| actual.is_a?(Dry::Monads::Either::Left) }
  end

end
