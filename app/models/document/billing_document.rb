class BillingDocument < ActiveRecord::Base
  belongs_to :billing
  belongs_to :document
end
