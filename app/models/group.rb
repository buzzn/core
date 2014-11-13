class Group < ActiveRecord::Base
  resourcify
  acts_as_commentable
  include Authority::Abilities
  before_destroy :release_metering_points

  include PublicActivity::Model
  tracked  owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked  recipient: Proc.new{ |controller, model| controller && model }

  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  validates :name, presence: true, uniqueness: true, length: { in: 4..30 }

  normalize_attribute :name, with: [:strip]


  has_many :assets, as: :assetable, dependent: :destroy
  has_one  :metering_point_operator_contract, dependent: :destroy
  has_one  :servicing_contract, dependent: :destroy
  has_one  :area
  has_many :metering_points

  validates :metering_points, presence: true

  has_many :group_users
  has_many :users, :through => :group_users


  def member?(metering_point)
    self.metering_points.include?(metering_point) ? true : false
  end

  def received_group_metering_point_requests
    GroupMeteringPointRequest.where(group: self)
  end

  private

    def release_metering_points
      self.metering_points.each do |metering_point|
        metering_point.group = nil
        metering_point.save
      end
    end


end