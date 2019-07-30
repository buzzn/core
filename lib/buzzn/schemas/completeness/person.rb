require_relative '../completeness'

module Schemas::Completeness

  Person = Schemas::Support.Schema do
    # this might be to general here as not all Organizations need to have an Address only Organizations
    # as Owner of Localpool do
    required(:address).filled
  end

end
