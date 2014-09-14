class MeteringPoint < ActiveRecord::Base
  include Authority::Abilities

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
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
  has_many :devices

  has_many :metering_point_users
  has_many :users, :through => :metering_point_users

  validates :uid, uniqueness: true #presence: true
  validates :address_addition, presence: true

  def meter
    self.registers.collect(&:meter).first
  end

  def mode
    self.registers.select(:mode).map(&:mode).join('_')
  end

  scope :by_group_id_and_modes, lambda { |group_id, modes|
    MeteringPoint.joins(:registers).where("mode in (?)", modes).where(group_id: group_id).order('mode DESC')
  }


  def name
    case mode
    when 'in'
      address_addition
    when 'in_out'
      "#{mode} #{generator_type_names}-#{address_addition}"
    when 'out'
      "#{generator_type_names} #{address_addition}"
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



  def validates_smartmeter
    if meter && metering_service_provider_contract
      @mspc = metering_service_provider_contract
      @meter = meter

      discovergy = Discovergy.new(@mspc.username, @mspc.password, "EASYMETER_#{@meter.manufacturer_product_serialnumber}")
      result     = discovergy.call()
      if result['status'] == 'ok'
        @meter.update_columns(smart: true)
        first_day_init
      else
        @meter.update_columns(smart: false)
      end
    else
      @meter.update_columns(smart: false)
    end
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



  private


    def first_day_init
      metering_point = self
      register       = registers.first # TODO not compatible with in_out smartmeter
      mspc           = metering_point.metering_service_provider_contract

      date            = Time.now.in_time_zone
      beginning       = date.beginning_of_day
      ending          = date

      (beginning.to_i .. ending.to_i).step(1.minutes) do |time|
        start_time = time * 1000
        end_time   = Time.at(time).end_of_minute.to_i * 1000
        MeterReadingUpdateWorker.perform_async(
                                                register.id,
                                                meter.manufacturer_product_serialnumber,
                                                mspc.organization.name.downcase,
                                                mspc.username,
                                                mspc.password,
                                                start_time,
                                                end_time
                                              )
      end

    end



end
