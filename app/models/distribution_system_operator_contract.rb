class DistributionSystemOperatorContract < ActiveRecord::Base
  has_one :organization, as: :organizationable
  accepts_nested_attributes_for :organization, allow_destroy: true
end
