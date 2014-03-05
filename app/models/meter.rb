class Meter < ActiveRecord::Base
  resourcify
  include Authority::Abilities
end
