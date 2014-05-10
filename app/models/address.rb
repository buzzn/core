class Address < ActiveRecord::Base

  belongs_to :addressable, polymorphic: true

  validates :street,  presence: true
  validates :city,    presence: true
  validates :state,   presence: true
  validates :zip,     presence: true

  #after_validation :geocode

  geocoded_by :full_address

  def full_address
    [street, city, zip, state, country].compact.join(', ')
  end

  def name
    "#{street}, #{city}"
  end

end
