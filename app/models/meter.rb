class Meter < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  belongs_to :user

end
