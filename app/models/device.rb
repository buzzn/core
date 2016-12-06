require 'file_size_validator'
require 'buzzn/guarded_crud'
class Device < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include Filterable
  include PublicActivity::Model
  include Buzzn::GuardedCrud
  #tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  #tracked recipient: Proc.new{ |controller, model| controller && model }

  belongs_to :register, class_name: Register::Base

  mount_uploader :image, PictureUploader

  validates :mode, presence: true
  validates :manufacturer_name, presence: true, length: { in: 2..30 }
  validates :manufacturer_product_name, presence: true, length: { in: 2..30 }
  validates :watt_peak, numericality: { only_integer: true }, presence: true
  validates :image, :file_size => {
    :maximum => 2.megabytes.to_i
  }


  default_scope { order('created_at ASC') }

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }

  def self.outer_join
    'LEFT OUTER JOIN registers ON registers.id = devices.register_id'
  end

  def self.outer_join_where
    "registers.id = devices.register_id AND " +
      "devices.mode = 'out' AND " +
      "registers.group_id IS NOT NULL"
  end
  
  scope :readable_by, -> (user) do
    # TODO user AREL instead of activerecord DSL
    #      and EXISTS SELECT 1 WHERE ...
    if user
      joins("LEFT OUTER JOIN roles ON roles.resource_id = devices.id OR roles.resource_id IS NULL")
        .joins("LEFT OUTER JOIN users_roles ON users_roles.role_id = roles.id")
        .joins(outer_join)
        .where("#{outer_join_where} OR " +
               "(users_roles.user_id = ? OR users_roles.user_id in (?)) AND " +
               # manager role
               "(roles.resource_id = devices.id AND " +
               "roles.resource_type = '#{Device}' AND " +
               "roles.name = 'manager' OR " +
               # or admin role (with out associated resource)
               "roles.name = 'admin' AND roles.resource_id IS NULL)", user.id, user.friends.select('id'))
    else
      joins(outer_join).where(outer_join_where) 
    end
  end

  def self.accessible_by_user(user)
    device  = Device.arel_table
    manager = User.roles_query(user, manager: device[:id])
    where(manager.project(1).exists)
  end

  def self.search_attributes
    [:manufacturer_name, :manufacturer_product_name, :mode, :category,
     :shop_link]
  end

  def self.filter(search)
    do_filter(search, *search_attributes)
  end

  def name
    "#{self.manufacturer_name} #{self.manufacturer_product_name}"
  end


  def self.readables
    %w{
      me
      friends
      world
    }
  end

  def self.laws
    %w{
      eeg
      kwkg
    }.map(&:to_sym)
  end

  def self.modes
    %w{
      in
      out
    }
  end

  def self.primary_energies
    %w{
      gas
      oil
      lpg
      sun
      wind
      water
      biomass
    }.map(&:to_sym)
  end


  def output?
    self.mode == 'out'
  end

  def input?
    self.mode == 'in'
  end

  def in_and_output?
    self.mode == 'in_out'
  end

  def editable_users
    User.with_role(:manager, self).to_a
  end


end
