class Group < ActiveRecord::Base
  rolify
  include Authority::UserAbilities

  extend FriendlyId
  friendly_id :name, use: :slugged

end