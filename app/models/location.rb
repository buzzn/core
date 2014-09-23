class Location < ActiveRecord::Base
  resourcify
  include Authority::Abilities

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]
  def slug_candidates
    [
      :short_name,
      :id
    ]
  end


  def name
    short_name
  end

  delegate :short_name, to: :address, allow_nil: true
  delegate :long_name, to: :address, allow_nil: true


  has_many :users, -> { uniq }, :through => :metering_points
  has_many :devices, -> { uniq }, :through => :metering_points

  has_many :assets, as: :assetable, dependent: :destroy

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_many :metering_points, dependent: :destroy
  accepts_nested_attributes_for :metering_points, reject_if: :all_blank, allow_destroy: true

end
