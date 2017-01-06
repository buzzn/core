# coding: utf-8
class DiscovergyBroker < Broker

  attr_encrypted :provider_token_key, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key
  attr_encrypted :provider_token_secret, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

  def self.modes
    [:in, :out, :virtual]
  end

  validates :mode, inclusion:{ in: self.modes.map{|m| m.to_s} }

  validates :external_id, presence: true

  validates :resource_type, inclusion:{ in: [Group.to_s, Meter::Base.to_s] }
  validates :resource_id, presence: true

  validate :validates_invariants

  after_save :validates_credentials

  def validates_invariants
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
      data_result = Buzzn::Application.config.current_power.for_register(self.resource.registers.first, Time.current)
      if data_result
        self.resource.update_columns(smart: true)
        self.resource.save
      else
        self.resource.update_columns(smart: false)
        self.resource.save
      end
    end
  end
end
