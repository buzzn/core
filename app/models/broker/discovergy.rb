# coding: utf-8
class Broker::Discovergy < Broker::Base
  include Import.active_record['service.current_power']

  # TODO duplicate const as in Contract model, those validation consts
  #      need a common place
  IS_MISSING = 'is missing'

  attr_encrypted :provider_token_key, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key
  attr_encrypted :provider_token_secret, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

  def self.modes
    [:in, :out, :in_out, :virtual]
  end

  validates :mode, inclusion:{ in: self.modes.map{|m| m.to_s} }

  validates :external_id, presence: true
  validates :consumer_key, presence: false
  validates :consumer_secret, presence: false

  validates :resource_type, inclusion:{ in: [Group::Base.to_s, Meter::Base.to_s] }
  validates :resource_id, presence: true

  validate :validates_invariants

  def validates_invariants
    if provider_token_key || provider_token_secret
      errors.add(:provider_token_key, IS_MISSING) unless provider_token_key
      errors.add(:provider_token_secret, IS_MISSING) unless provider_token_secret
    end
    if self.consumer_key || self.consumer_secret
      errors.add(:consumer_key, IS_MISSING) unless self.consumer_key
      errors.add(:consumer_secret, IS_MISSING) unless self.consumer_secret
    end
    case mode.to_sym
    when :virtual
      if ! resource.is_a?(Meter::Virtual)
        errors.add(:resourcable, 'can not be virtual on non-virtual Meters')
      end
      if resource_type.is_a?(Group::Base)
        errors.add(:mode, 'can not be virtual for Group resource')
      end
    when :in_out
      if !(resource.is_a?(Meter::Real) && resource.registers.size == 2)
        errors.add(:mode, 'can not be in_out on a Meter without two Registers')
      end
    else
      if !(resource.is_a?(Meter::Real) && resource.registers.size == 1) && !resource.is_a?(Group::Base)
        errors.add(:mode, "can not be 'in' or 'out' on a Meter with more or less than one Register")
      end
      if resource.is_a?(Meter::Real) && resource.registers.first.is_a?(Register::Input) && mode.to_sym == :out
        errors.add(:mode, "for a Register::Input is 'out' but should be 'in'")
      end
      if resource.is_a?(Meter::Real) && resource.registers.first.is_a?(Register::Output) && mode.to_sym == :in
        errors.add(:mode, "for a Register::Output is 'in' but should be 'out'")
      end
    end
  end

  def self.in(group)
    do_get(:in, group)
  end

  def self.out(group)
    do_get(:out, group)
  end

  def self.virtual(meter)
    do_get(:virtual, meter)
  end

  def two_way_meter?
    # produce a ternary result: group is nil, register will use true or false
    if self.resource.is_a?(Meter::Real)
      self.resource.input_register != nil && self.resource.output_register != nil
    end
  end
end
