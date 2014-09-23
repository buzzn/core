class Address < ActiveRecord::Base

  belongs_to :addressable, polymorphic: true

  validates :street_name,     presence: true
  validates :street_number,   presence: true
  validates :city,            presence: true
  validates :state,           presence: true
  validates :zip,             presence: true

  after_validation :geocode if Rails.env == 'production'
  geocoded_by :full_name

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
