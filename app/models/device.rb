require 'file_size_validator'

class Device < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include Filterable
  include PublicActivity::Model
  #tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  #tracked recipient: Proc.new{ |controller, model| controller && model }

  belongs_to :metering_point

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

  scope :readable_by, -> (user) do
    if user
      if user.has_role?(:admin)
        where(nil)
      else
        where("metering_points.id = devices.metering_point_id and devices.mode = 'out' and metering_points.group_id is not null or (users_roles.user_id = ? or users_roles.user_id in (?))", user.id, user.friends.select('id')).joins("INNER JOIN roles ON roles.resource_id = devices.id AND roles.resource_type = '#{Device}' INNER JOIN users_roles ON users_roles.role_id = roles.id").joins('LEFT OUTER JOIN metering_points ON metering_points.id = devices.metering_point_id')
      end
    else
      where("1=0") #empty set
    end
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
