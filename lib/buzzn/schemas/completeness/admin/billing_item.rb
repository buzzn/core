require_relative '../admin'

module Schemas::Completeness::Admin

  BillingItem = Schemas::Support.Schema do

    required(:begin_reading).filled
    required(:end_reading).filled

  end

end
