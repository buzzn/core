class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  validates :street, presence: true, uniqueness: true
  validates :city, presence: true, uniqueness: true
  validates :state, presence: true, uniqueness: true
  validates :zip, presence: true, uniqueness: true

  def name
    "#{street} #{zip} #{city}"
  end

end
