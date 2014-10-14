class MeteringPoint < ActiveRecord::Base
  include Authority::Abilities
  include PublicActivity::Model

  has_ancestry

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
  def slug_candidates
    [
      :uid,
      :id
    ]
  end


  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }



  belongs_to :location

  belongs_to :group

  has_many :registers, dependent: :destroy
  accepts_nested_attributes_for :registers, reject_if: :all_blank

  has_many :electricity_supplier_contracts,         dependent: :destroy
  has_many :metering_service_provider_contracts,    dependent: :destroy
  has_many :metering_point_operator_contracts,      dependent: :destroy
  has_many :distribution_system_operator_contracts, dependent: :destroy

  has_many :devices

  has_many :metering_point_users
  has_many :users, through: :metering_point_users, dependent: :destroy

  validates :uid, uniqueness: true #presence: true
  validates :address_addition, presence: true

  def meter
    self.registers.collect(&:meter).first
  end

  def mode
    self.registers.select(:mode).map(&:mode).join('_')
  end

  def metering_point_operator_contract
    if self.metering_point_operator_contracts.any?
      self.metering_point_operator_contracts.first
    elsif self.group
      self.group.metering_point_operator_contract
    end
  end

  scope :by_group_id_and_modes, lambda { |group_id, modes|
    MeteringPoint.joins(:registers).where("mode in (?)", modes).where(group_id: group_id).order('mode DESC')
  }

  scope :by_modes_and_user, lambda {|modes, user|
    if modes == "in_out"
      modes = ["in", "out", "in_out"]
    end
    location_ids = user.editable_locations.collect{|location| location.id}
    root_metering_points = location_ids.collect{|location_id| Location.find(location_id).metering_point.id}.join('|')
    MeteringPoint.joins(:registers).where("mode in (?)", modes).where(group_id: nil).where("location_id in (?) OR ancestry SIMILAR TO ?", location_ids, root_metering_points).collect(&:id)
  }






  def validates_smartmeter
    if meter && (metering_point_operator_contract || self.group.metering_point_operator_contract)
      @mpoc = metering_point_operator_contract
      @meter = meter

      discovergy = Discovergy.new(@mpoc.username, @mpoc.password, "EASYMETER_#{@meter.manufacturer_product_serialnumber}")
      result     = discovergy.call()
      if result['status'] == 'ok'
        @meter.update_columns(smart: true)
        first_day_init
      else
        @meter.update_columns(smart: false)
      end
    else
      meter.update_columns(smart: false)
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



  def output?
    self.mode == 'out'
  end

  def input?
    self.mode == 'in'
  end

  def in_and_output?
    self.mode == 'in_out'
  end




  def self.json_tree(nodes)
    nodes.map do |node, sub_nodes|
      {:name => node.address_addition, :id => node.slug, :data => {:mode => node.mode}, :children => json_tree(sub_nodes).compact}
    end
  end



  private

    def first_day_init
      metering_point = self
      register       = registers.first # TODO not compatible with in_out smartmeter
      mpoc           = metering_point.metering_point_operator_contract
      date           = Time.now.in_time_zone
      beginning      = date.beginning_of_day
      ending         = date
      (beginning.to_i .. ending.to_i).step(1.minutes) do |time|
        start_time = time * 1000
        end_time   = Time.at(time).end_of_minute.to_i * 1000
        MeterReadingUpdateWorker.perform_async(
                                                register.id,
                                                meter.manufacturer_product_serialnumber,
                                                mpoc.organization.name.downcase,
                                                mpoc.username,
                                                mpoc.password,
                                                start_time,
                                                end_time
                                              )
      end
    end



end
