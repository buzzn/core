class Address < ActiveRecord::Base

  belongs_to :addressable, polymorphic: true

  validates :street,  presence: true
  validates :city,    presence: true
  validates :state,   presence: true
  validates :zip,     presence: true

  def name
    "#{street} #{zip} #{city}"
  end

end
