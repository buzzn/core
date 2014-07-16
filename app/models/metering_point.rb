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
    return  { current: Register.find(1).day_to_hours, past: Register.find(1).day_to_hours }
  end

  def week_to_days
    current = [[1404864000000, 8], [1404864000000 + 1*3600*1000, 3], [1404864000000 + 2*3600*1000, 2], [1404864000000 + 3*3600*1000, 7], [1404864000000 + 4*3600*1000, 8], [1404864000000 + 5*3600*1000, 10], [1404864000000 + 6*3600*1000, 11], [1404864000000 + 7*3600*1000, 9], [1404864000000 + 8*3600*1000, 5], [1404864000000 + 9*3600*1000, 13], [1404864000000 + 10*3600*1000, 10], [1404864000000 + 11*3600*1000, 12], [1404864000000 + 12*3600*1000, 10], [1404864000000 + 13*3600*1000, 14], [1404864000000 + 14*3600*1000, 13], [1404864000000 + 15*3600*1000, 13], [1404864000000 + 16*3600*1000, 10], [1404864000000 + 17*3600*1000, 8], [1404864000000 + 18*3600*1000, 10], [1404864000000 + 19*3600*1000, 9], [1404864000000 + 20*3600*1000, 7]]
    past    = [[1404864000000, 1], [1404864000000 + 1*3600*1000, 5], [1404864000000 + 2*3600*1000, 1], [1404864000000 + 3*3600*1000, 4], [1404864000000 + 4*3600*1000, 10], [1404864000000 + 5*3600*1000, 12], [1404864000000 + 6*3600*1000, 9], [1404864000000 + 7*3600*1000, 8], [1404864000000 + 8*3600*1000, 5], [1404864000000 + 9*3600*1000, 10], [1404864000000 + 10*3600*1000, 11], [1404864000000 + 11*3600*1000, 9], [1404864000000 + 12*3600*1000, 13], [1404864000000 + 13*3600*1000, 16], [1404864000000 + 14*3600*1000, 14], [1404864000000 + 15*3600*1000, 10], [1404864000000 + 16*3600*1000, 10], [1404864000000 + 17*3600*1000, 12], [1404864000000 + 18*3600*1000, 11], [1404864000000 + 19*3600*1000, 10], [1404864000000 + 20*3600*1000, 9]]
    return  { current: current, past: past }
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
