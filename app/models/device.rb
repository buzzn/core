class Device < ActiveRecord::Base

  belongs_to :register, class_name: 'Register::Base', foreign_key: :register_id

  belongs_to :localpool, class_name: 'Group::Localpool', foreign_key: :localpool_id

  enum law: { eeg: 'eeg', kwkg: 'kwkg', free: 'free' }

  enum two_way_meter: { yes: 'yes', planned: 'planned' }

  enum two_way_meter_used: { used_yes: 'yes', used_planned: 'planned' }

  enum primary_energy: %i(bio_mass bio_gas natural_gas fluid_gas fuel_oil wood veg_oil sun wind water other).each_with_object({}) { |i, map| map[i] = i.to_s }

end
