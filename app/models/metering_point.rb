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

  has_many :assets, as: :assetable, dependent: :destroy

  has_many :devices

  has_many :metering_point_users
  has_many :users, through: :metering_point_users, dependent: :destroy

  validates :uid, uniqueness: true, length: { in: 4..34 } #presence: true
  validates :address_addition, presence: true, length: { in: 2..30 }

  def meter
    self.registers.collect(&:meter).first
  end

  def mode
    self.registers.select(:mode).map(&:mode).join('_')
  end

  def metering_point_operator_contract
    if self.metering_point_operator_contracts.running.any?
      return self.metering_point_operator_contracts.running.first
    elsif self.group
      if self.group.metering_point_operator_contract
        return self.group.metering_point_operator_contract
      end
    end
  end

  scope :by_group_id_and_modes, lambda { |group_id, modes|
    MeteringPoint.joins(:registers).where("mode in (?)", modes).where(group_id: group_id).order('mode DESC')
  }

  scope :by_modes_and_user_without_group, lambda {|modes, user|
    if modes == "in_out"
      modes = ["in", "out", "in_out"]
    end
    location_ids = user.editable_locations.collect{|location| location.id if location.metering_point}.compact
    subtree_metering_points = location_ids.collect{|location_id| Location.find(location_id).metering_point.subtree_ids}.join('/%|') + "/%"
    root_metering_points = location_ids.collect{|location_id| Location.find(location_id).metering_point.id}.join('|')
    MeteringPoint.joins(:registers).where("mode in (?)", modes).where(group_id: nil).where("location_id in (?) OR ancestry SIMILAR TO ? OR ancestry SIMILAR TO ?", location_ids, subtree_metering_points, root_metering_points)
  }

  scope :by_modes_and_user, lambda {|modes, user|
    if modes == "in_out"
      modes = ["in", "out", "in_out"]
    end
    location_ids = user.editable_locations.collect{|location| location.id if location.metering_point}.compact
    subtree_metering_points = location_ids.collect{|location_id| Location.find(location_id).metering_point.subtree_ids}.join('/%|') + "/%"
    root_metering_points = location_ids.collect{|location_id| Location.find(location_id).metering_point.id}.join('|')
    MeteringPoint.joins(:registers).where("mode in (?)", modes).where("location_id in (?) OR ancestry SIMILAR TO ? OR ancestry SIMILAR TO ?", location_ids, subtree_metering_points, root_metering_points)
  }



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
      label = node.decorate.name
      if node.mode == "out" && node.devices.any?
        label = label + " | " + node.devices.first.name
      end
      {:label => label, :mode => node.mode, :children => json_tree(sub_nodes).compact}
    end
  end





end
