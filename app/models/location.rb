class Location < ActiveRecord::Base
  resourcify
  include Authority::Abilities
  include Tokenable

  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller && controller.current_user }
  tracked recipient: Proc.new{ |controller, model| controller && model }

  before_destroy :check_for_metering_point

  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :generate_token,
      :id
    ]
  end

  def name
    short_name
  end

  delegate :short_name, to: :address, allow_nil: true
  delegate :long_name, to: :address, allow_nil: true

  has_many :users, -> { uniq }, :through => :metering_point
  has_many :devices, -> { uniq }, :through => :metering_point

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank

  has_one :metering_point


  private

  def check_for_metering_point
    unless metering_point.nil?
      return false
    end
  end

end
