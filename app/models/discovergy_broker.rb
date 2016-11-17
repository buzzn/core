# coding: utf-8
class DiscovergyBroker < ActiveRecord::Base

  belongs_to :resourcable, polymorphic: true

  def self.modes
    [:in, :out, :virtual]
  end

  validates :mode, inclusion:{ in: self.modes }

  validates :external_id, presence: true
  validates :provider_login, presence: true
  validates :provider_password, presence: true

  validates :resource_type, inclusion:{ in: [Group.to_s, Register.to_s] }
  validates :resource_id, presence: true

  validate :validates_invariants

  def validates_invariants
    case mode
    when :virtual
      if ! resourcable.virtual?
        errors.add(:resourcable, 'Register needs to be virtual itself')
      end
      if resource_type == Group.to_s
        errors.add(:mode, 'can not be virtual for Group resource')
      end
    else
      if resource_type == Register.to_s
        errors.add(:mode, 'has to be virtual for Register resource')
      end
    end
  end

  def self.in(group)
    do_get(:in, group)
  end

  def self.out(group)
    do_get(:out, group)
  end

  def self.virtual(register)
    do_get(:virtual, register)
  end

  private

  def self.do_get(mode, resource)
    result = where(mode: mode, resource_type: resource.class,
                   resource_id: resource.id).first
    if result.nil?
      raise ActiveRecord::NotFound.new
    end
    result
  end
end
