# coding: utf-8
class Address < ActiveRecord::Base

  belongs_to :addressable, polymorphic: true

  validates :street_name,     presence: true, length: { in: 2..128 }
  validates :street_number,   presence: true, length: { in: 1..32 }
  validates :city,            presence: true, length: { in: 2..128 }
  validates :state,           presence: false
  validates :zip,             presence: true, numericality: { only_integer: true }


  after_validation :geocode if Rails.env == "production" || Rails.env == "staging"
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

  def self.states
    %w{
      Baden-Würrtemberg
      Bayern
      Berlin
      Brandenburg
      Bremen
      Hamburg
      Hessen
      Niedersachsen
      Nordrhein-Westfalen
      Mecklemburg-Vorpommern
      Rheinland-Pfalz
      Saarland
      Sachsen
      Sachsen-Anhalt
      Schleswig-Holstein
      Thüringen
    }
  end

  def self.filter(value)
    do_filter(value, :city, :street_name)
  end

  def street_with_number
    "#{street_name} #{street_number}"
  end

  def street_with_number_and_extra
    "#{street_name} #{street_number} #{address}"
  end

  def zip_with_place
    "#{zip} #{city}"
  end

  def street_number_zip_place
    "#{street_name} #{street_number}, #{zip} #{city}"
  end
end
