# coding: utf-8
require 'buzzn/guarded_crud'
class Address < ActiveRecord::Base
  include Authority::Abilities
  include Buzzn::GuardedCrud

  belongs_to :addressable, polymorphic: true

  validates :street_name,     presence: true, length: { in: 2..128 }
  validates :street_number,   presence: true, length: { in: 1..32 }
  validates :city,            presence: true, length: { in: 2..128 }
  #validates :state,           presence: true
  validates :zip,             presence: true, numericality: { only_integer: true }


  after_validation :geocode
  geocoded_by :full_name

  default_scope -> { order(:created_at => :asc) }

  def self.orga_address
    address = Address.arel_table
    organization = Organization.arel_table
    orga_address = organization.where(organization[:id].eq(address[:addressable_id]))
  end
  private_class_method :orga_address

  scope :readable_by, ->(user) do
    if user.nil?
      where(orga_address.project(1).exists)
    else
      address = Address.arel_table
      # assume register.id and contracting_party.id are unique overall
      admin_or_manager_of_register = User.roles_query(user, manager: address[:addressable_id], admin: nil)

      contracting_party = ContractingParty.arel_table
      contracting_party_owner = contracting_party.where(contracting_party[:id].eq(address[:addressable_id]).and(contracting_party[:user_id].eq(user.id)))

      users_roles    = Role.users_roles_arel_table
      role           = Role.arel_table
      friendship     = Friendship.arel_table
      register       = Register::Base.arel_table

      # assume address[:addressable_id] is the register
      register_managers = users_roles
                      .join(role)
                      .on(role[:id].eq(users_roles[:role_id]).and(role[:resource_id].eq(address[:addressable_id])).and(role[:name].eq('manager')))
                      .where(users_roles[:user_id].eq(friendship[:user_id]))
      manager_friends =
        friendship.where(friendship[:friend_id].eq(user.id)
                          .and(register_managers.project(1).exists)
                          .and(register
                                .where(register[:id].eq(address[:addressable_id])
                                        .and(register[:readable].eq(:friends))).project(1).exists))

      organization = Organization.arel_table
      orga_managers = users_roles
                      .join(role)
                      .on(role[:id].eq(users_roles[:role_id]).and(role[:resource_id].eq(contracting_party[:organization_id])).and(role[:name].eq('manager')).and(role[:resource_type].eq(Organization.to_s)))
                      .where(users_roles[:user_id].eq(user.id))
      orga_contracting_party =
        contracting_party.where(contracting_party[:id].eq(address[:addressable_id])
                            .and(orga_managers.project(1).exists))


      sqls = [admin_or_manager_of_register,
              contracting_party_owner,
              orga_address,
              orga_contracting_party,
              manager_friends].collect do |query|
        query.project(1).exists.to_sql
      end

      where(sqls.join(' OR '))
    end
  end

  def register
    Register::Base.find(addressable_id)
  end

  def full_name
    [ street_name, street_number, city, zip, state, country].compact.join(', ')
  end

  def long_name
    "#{street_name} #{street_number}, #{city}"
  end

  def short_name
    "#{street_name} #{city}"
  end

  def self.states
    %w{
      Baden-Würrtemberg
      Bayern
      Berlin
      Brandenburg
      Bremen
      Hamburg
      Hessen
      Niedersachsen
      Nordrhein-Westfalen
      Mecklemburg-Vorpommern
      Rheinland-Pfalz
      Saarland
      Sachsen
      Sachsen-Anhalt
      Schleswig-Holstein
      Thüringen
    }
  end

  def self.filter(value)
    do_filter(value, :city, :street_name)
  end

end
