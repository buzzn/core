require 'dry-types'

module Buzzn
  module Types
    MeterTypes = Types::Strict::Symbol.enum(:single, :double, :smart)
  end
end
