# coding: utf-8
class DiscovergyBroker < Broker

  # TODO duplicate const as in Contract model, those validation consts
  #      need a common place
  IS_MISSING = 'is missing'
  
  attr_encrypted :provider_token_key, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key
  attr_encrypted :provider_token_secret, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

  def self.modes
    [:in, :out, :virtual]
  end

  validates :mode, inclusion:{ in: self.modes.map{|m| m.to_s} }

  validates :external_id, presence: true
  validates :consumer_key, presence: false
  validates :consumer_secret, presence: false

  validates :resource_type, inclusion:{ in: [Group.to_s, Meter::Base.to_s] }
  validates :resource_id, presence: true

  validate :validates_invariants

  # TODO: bring back after PROD deploy
  #after_commit :validates_credentials

  def validates_invariants
    if provider_token_key || provider_token_secret
      errors.add(:provider_token_key, IS_MISSING) unless provider_token_key
      errors.add(:provider_token_secret, IS_MISSING) unless provider_token_secret
    end
    if self.consumer_key || self.consumer_secret
      errors.add(:consumer_key, IS_MISSING) unless self.consumer_key
      errors.add(:consumer_secret, IS_MISSING) unless self.consumer_secret
    end
    case mode
    when :virtual
      if ! resourcable.virtual?
        errors.add(:resourcable, 'Meter needs to be virtual itself')
      end
      if resource_type == Group.to_s
        errors.add(:mode, 'can not be virtual for Group resource')
      end
    # else
    #   if resource_type == Meter.to_s
    #     errors.add(:mode, 'has to be virtual for Meter resource')
    #   end
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
    two_way_meter = self.resource.is_a?(Meter::Real) && self.resource.input_register != nil && self.resource.output_register != nil
  end

  private

  # TODO: Move this into parent class
  def validates_credentials
    if self.resource.is_a?(Meter::Real) && self.resource.registers.any?
      data_result = Buzzn::Application.config.current_power.for_register(self.resource.registers.first)
      if data_result
        self.resource.update_columns(smart: true)
        self.resource.reload
      else
        self.resource.update_columns(smart: false)
        self.resource.reload
      end
    end
  end
end
