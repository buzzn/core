require 'dry-types'

module Buzzn
  module Types
    MeterTypes = Types::Strict::String.enum('single', 'double', 'smart')
  end
end
