class Dashboard < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :user

  has_many :dashboard_registers
  has_many :registers, :through => :dashboard_registers

end
