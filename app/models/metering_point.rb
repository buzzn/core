class MeteringPoint < ActiveRecord::Base
  include Authority::Abilities

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]#, :use => :scoped, :scope => :location
  def slug_candidates
    [
      name,
      :uid
    ]
  end


  belongs_to :location
  acts_as_list scope: :location

  belongs_to :contract, dependent: :destroy

  belongs_to :group

  has_one :register, dependent: :destroy
  accepts_nested_attributes_for :register, reject_if: :all_blank

  has_one :distribution_system_operator_contract, dependent: :destroy
  has_one :electricity_supplier_contract, dependent: :destroy
  has_one :metering_service_provider_contract, dependent: :destroy
  has_many :devices, dependent: :destroy

  has_many :metering_point_users
  has_many :users, :through => :metering_point_users

  #validates :uid, uniqueness: true
  validates :mode, presence: true
  validates :address_addition, presence: true

  def name
    case mode
    when 'up'
      "#{mode} #{generator_type_names}-#{self.address_addition}"
    when 'down'
      address_addition
    end
  end


  def generator_type_names
    names = []
    generator_types = devices.map {|i| i.generator_type }.uniq
    generator_types.each do |type|
      names << t("#{type}_short")
    end
    return names.join(', ')
  end




  def self.modes
    %w{
      up
      down
      up_down
    }
  end

  def self.voltages
    %w{
      low
      medium
      high
      highest
    }
  end

  def self.regular_intervals
    %w{
      monthly
      annually
      quarterly
      half_yearly
    }
  end


  def up?
    self.mode == 'up'
  end

  def down?
    self.mode == 'down'
  end

  def up_down?
    self.mode == 'up_down'
  end

end
