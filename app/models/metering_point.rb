class MeteringPoint < ActiveRecord::Base
  include Authority::Abilities

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }

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

  has_many :registers, dependent: :destroy
  accepts_nested_attributes_for :registers, reject_if: :all_blank

  has_one :distribution_system_operator_contract, dependent: :destroy
  has_one :electricity_supplier_contract, dependent: :destroy
  has_one :metering_service_provider_contract, dependent: :destroy
  has_many :devices, dependent: :destroy

  has_many :metering_point_users
  has_many :users, :through => :metering_point_users

  validates :uid, uniqueness: true #presence: true
  validates :address_addition, presence: true


  def mode
    self.registers.select(:mode).map(&:mode).join('_')
  end

  #scope :output, self.joins(:registers).where("mode = 'out'")

  scope :by_group_id_and_mode_eq, lambda { |group_id, mode|
    MeteringPoint.joins(:registers).where("mode = '#{mode}'").where(group_id: group_id).uniq
  }


  def name
    case mode
    when 'in'
      address_addition
    when 'in_out'
      "#{mode} #{generator_type_names}-#{address_addition}"
    when 'out'
      "#{mode} #{generator_type_names}-#{address_addition}"
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

  def self.types
    %w{
      2_way_meter
      one_of_two_meter
      virtual_meter
      demarcation_meter
    }
  end

  def in_out?
    mode == 'in_out'
  end

  def out?
    mode == 'out'
  end

  def in?
    mode == 'in'
  end


end
