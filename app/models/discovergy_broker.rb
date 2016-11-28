# coding: utf-8
class DiscovergyBroker < ActiveRecord::Base

  attr_encrypted :provider_login, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key
  attr_encrypted :provider_password, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key
  attr_encrypted :provider_token_key, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key
  attr_encrypted :provider_token_secret, :charset => 'UTF-8', :key => Rails.application.secrets.attr_encrypted_key

  belongs_to :resource, polymorphic: true

  def self.modes
    [:in, :out, :virtual]
  end

  validates :mode, inclusion:{ in: self.modes.map{|m| m.to_s} }

  validates :external_id, presence: true
  validates :provider_login, presence: true
  validates :provider_password, presence: true

  validates :resource_type, inclusion:{ in: [Group.to_s, Meter.to_s] }
  validates :resource_id, presence: true

  validate :validates_invariants

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

  private

  def self.do_get(mode, resource)
    # we have unique index on these three attributes
    result = where(mode: mode, resource_type: resource.class,
                   resource_id: resource.id).first
    if result.nil?
      raise ActiveRecord::NotFound.new
    end
    result
  end
end
