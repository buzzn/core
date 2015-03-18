class MeteringPoint < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include PublicActivity::Model

  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }


  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :uid,
      :slug_name
    ]
  end


  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }


  belongs_to :group

  belongs_to :meter

  has_one :register, dependent: :destroy
  accepts_nested_attributes_for :register, reject_if: :all_blank

  has_many :contracts, dependent: :destroy
  has_many :devices
  has_many :metering_point_users
  has_many :users, through: :metering_point_users, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy

  validates :uid, uniqueness: true, length: { in: 4..34 }, allow_blank: true
  validates :name, presence: true, length: { in: 2..30 }

  mount_uploader :image, PictureUploader

  delegate :mode, to: :register, allow_nil: true



  default_scope { order('created_at ASC') }

  scope :outputs, lambda { self.joins(:register).where("mode in (?)", 'out') }
  scope :inputs,  lambda { self.joins(:register).where("mode in (?)", 'in') }

  scope :without_group, lambda { self.where(group: nil) }

  scope :editable_by_user, lambda {|user|
    self.with_role(:manager, user)
  }

  scope :by_group, lambda {|group|
    self.where(group: group.id)
  }

  scope :by_group_id_and_modes, lambda { |group_id, modes|
    MeteringPoint.joins(:register).where("mode in (?)", modes)
  }



  def smart?
    if meter
      meter.smart
    else
      false
    end
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
      if self.group.contracts.metering_point_operators.running.any?
        return self.group.contracts.metering_point_operators.running.first
      end
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

  def slug_name
    SecureRandom.uuid
  end


end
















