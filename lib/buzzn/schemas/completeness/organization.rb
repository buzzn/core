require_relative '../completeness'

module Schemas::Completeness

  Organization = Schemas::Support.Schema do
    required(:contact).filled
    # this might be to general here as not all Organizations need to have an Address only Organizations
    # as Owner of Localpool do
    required(:address).filled
  end

end
