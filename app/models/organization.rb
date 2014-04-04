class Organization < ActiveRecord::Base
  belongs_to :organizationable, polymorphic: true
end
