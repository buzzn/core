class Address < ActiveRecord::Base

  belongs_to :addressable, polymorphic: true

  validates :street_name,     presence: true
  validates :street_number,   presence: true
  validates :city,            presence: true
  validates :state,           presence: true
  validates :zip,             presence: true

  #after_validation :geocode

  geocoded_by :full_address

  def full_address
    [ street_name, street_number, city, zip, state, country].compact.join(', ')
  end

  def name
    "#{street_name}, #{city}"
  end

end
