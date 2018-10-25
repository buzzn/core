require_relative 'base_resource'

module Register
  class RealResource < BaseResource

    model Real

    attributes :pre_decimal_position,
               :post_decimal_position,
               :low_load_ability,
               :obis

    has_many :devices

  end
end
