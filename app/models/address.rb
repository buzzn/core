# coding: utf-8
class Address < ActiveRecord::Base
  include Authority::Abilities
  include Buzzn::GuardedCrud

  belongs_to :addressable, polymorphic: true

  validates :street_name,     presence: true, length: { in: 2..128 }
  validates :street_number,   presence: true, length: { in: 1..32 }
  validates :city,            presence: true, length: { in: 2..128 }
  validates :state,           presence: false
  validates :zip,             presence: true, numericality: { only_integer: true }


  after_validation :geocode
  geocoded_by :full_name

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
      address      = Address.arel_table
      users_roles  = Role.users_roles_arel_table
      user_table   = User.arel_table
      role         = Role.arel_table
      friendship   = Friendship.arel_table
      register     = Register::Base.arel_table
      organization = Organization.arel_table

      # assume all IDs are globally unique
      admin_or_manager_of_register = User.roles_query(user, manager: address[:addressable_id], admin: nil)

      register_managers = User.roles_query(friendship[:user_id], manager: address[:addressable_id])
      friends_of_register_manager =
        friendship.where(friendship[:friend_id].eq(user.id)
                          .and(register_managers.project(1).exists)
                          .and(register
                                .where(register[:id].eq(address[:addressable_id])
                                        .and(register[:readable].eq(:friends))).project(1).exists))
      orga_managers =  User.roles_query(user, manager: address[:addressable_id]).where(users_roles[:user_id].eq(user.id).and(role[:resource_type].eq(Organization)))
      user_address = user_table.where(address[:addressable_id].eq(user_table[:id]))   
      sqls = [admin_or_manager_of_register,
              orga_address,
              user_address,
              friends_of_register_manager].collect do |query|
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
