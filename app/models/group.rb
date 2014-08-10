class Group < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  include PublicActivity::Model
  tracked  owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked  recipient: Proc.new{ |controller, model| controller && model }

  mount_uploader :image, PictureUploader

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  validates :name, presence: true, uniqueness: true

  normalize_attribute :name, with: [:strip]

  has_one :area
  has_many :metering_points

  has_many :group_users
  has_many :users, :through => :group_users

  scope :by_group_id_and_mode_eq, lambda { |group_id, mode|
    MeteringPoint.joins(:registers).where("mode = '#{mode}'").where(group_id: group_id).uniq
  }


  def member?(metering_point)
    self.metering_points.include?(metering_point) ? true : false
  end

  def received_group_metering_point_requests
    GroupMeteringPointRequest.where(group: self)
  end

end