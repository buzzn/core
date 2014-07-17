class MeteringPoint < ActiveRecord::Base
  include Authority::Abilities

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]#, :use => :scoped, :scope => :location
  def slug_candidates
    [
      :uid,
      :id
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

  #validates :uid, presence: true, uniqueness: true
  validates :address_addition, presence: true


  delegate :mode, to: :register, allow_nil: true



  #scope :output, self.joins(:register).where("mode = 'out'")

  scope :by_group_id_and_mode_eq, lambda { |group_id, mode|
    MeteringPoint.joins(:register).where("mode = '#{mode}'").where(group_id: group_id).uniq
  }


  def name
    case mode
    when 'out'
      "#{mode} #{generator_type_names}-#{address_addition}"
    when 'in'
      address_addition
    end
  end


  def generator_type_names
    names = []
    generator_types = devices.map {|i| i.generator_type }.uniq
    generator_types.each do |type|
      names << "#{type}_short"
    end
    return names.join(', ')
  end


  def day_to_hours
    #return { current: Register.find(1).day_to_hours, past: Register.find(1).day_to_hours }
    return  { current: Register.day_to_hours, past: Register.day_to_hours }
  end

  def month_to_days
    return  { current: Register.month_to_days, past: Register.month_to_days }
  end

  def year_to_months
    return  { current: Register.year_to_months, past: Register.year_to_months }
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


  def out?
    mode == 'out'
  end

  def in?
    mode == 'in'
  end


end
