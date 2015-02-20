class MeteringPoint < ActiveRecord::Base
  resourcify
  has_ancestry
  include Authority::Abilities
  include PublicActivity::Model

  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }

  before_destroy :check_for_active_contracts

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
  def slug_candidates
    [
      :uid,
      :name
    ]
  end


  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }


  belongs_to :location
  belongs_to :group
  has_many :registers
  has_many :contracts,         dependent: :destroy
  has_many :devices
  has_many :metering_point_users
  has_many :users, through: :metering_point_users, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank


  validates :uid, uniqueness: true, length: { in: 4..34 }, allow_blank: true
  validates :name, presence: true, length: { in: 2..30 }

  mount_uploader :image, PictureUploader

  default_scope { order('created_at ASC') }



  def meter
    registers.collect(&:meter).first
  end

  def mode
    registers.select(:mode).map(&:mode).join('_')
  end

  def addable_devices
    @users = []
    @users << self.users
    @users << User.with_role(:manager, self)
    (@users).flatten.uniq.collect{|u| u.editable_devices }.flatten
  end

  def metering_point_operator_contract
    if self.contracts.metering_point_operators.running.any?
      return self.contracts.metering_point_operators.running.first
    elsif self.group
      if self.group.contracts.metering_point_operators
        return self.group.contracts.metering_point_operators
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
    metering_points_ids = user.editable_metering_points.collect{|metering_point| metering_point.id if metering_point}.compact
    subtree_metering_points = metering_points_ids.collect{|metering_points_id| MeteringPoint.find(metering_points_id).subtree_ids}.join('/%|') + "/%"
    root_metering_points = metering_points_ids.collect{|metering_points_id| MeteringPoint.find(metering_points_id).id}.join('|')
    MeteringPoint.joins(:registers).where("mode in (?)", modes).where(group_id: nil).where("metering_point_id in (?) OR ancestry SIMILAR TO ? OR ancestry SIMILAR TO ?", metering_points_ids, subtree_metering_points, root_metering_points)
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
      {:label => label, :mode => node.mode, :id => node.id, :children => json_tree(sub_nodes).compact}
    end
  end

  private

  def check_for_active_contracts
    if electricity_supplier_contracts.collect(&:status).compact.include?("running") || metering_point_operator_contracts.collect(&:running).compact.include?(true)
      return false
    end
  end





end
