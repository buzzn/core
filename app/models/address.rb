# coding: utf-8
class Address < ActiveRecord::Base
  include Authority::Abilities

  belongs_to :addressable, polymorphic: true

  validates :street_name,     presence: true
  validates :street_number,   presence: true
  validates :city,            presence: true
  #validates :state,           presence: true
  validates :zip,             presence: true, numericality: { only_integer: true }


  after_validation :geocode
  geocoded_by :full_name

  default_scope -> { order(:created_at => :asc) }


  def metering_point
    MeteringPoint.find(addressable_id)
  end

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

end
