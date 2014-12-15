class Address < ActiveRecord::Base

  belongs_to :addressable, polymorphic: true

  validates :street_name,     presence: true, length: { in: 4..30 }
  validates :street_number,   presence: true
  validates :city,            presence: true
  validates :state,           presence: true
  validates :zip,             presence: true, numericality: { only_integer: true }, length: { is: 5 }
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.zones_map(&:name).keys


  after_validation :geocode if Rails.env == 'production'
  geocoded_by :full_name

  default_scope -> { order(:created_at => :desc) }



  def full_name
    [ street_name, street_number, city, zip, state, country].compact.join(', ')
  end

  def long_name
    "#{street_name} #{street_number}, #{city}"
  end

  def short_name
    "#{street_name} #{city}"
  end

end
