# coding: utf-8
class Address < ActiveRecord::Base

  belongs_to :addressable, polymorphic: true

  # example:
  #   germany: 'DE'
  #   austria: 'AT'
  #   switzerland: 'CH'
  #   ...
  COUNTRIES = []
  ISO3166::Country.all.each_with_object({}) do |c, o|
    o[c.name.gsub(/[().,]/,'').gsub(/ /, '_').downcase] = c.alpha2
    COUNTRIES << c.alpha2
  end.tap do |map|
    enum country: map
  end
  # ['DE', 'AT', 'GB', ...]
  COUNTRIES.freeze

  # DE_BB: Brandenburg
  # DE_BE: Berlin
  # DE_BW: Baden-Württemberg
  # DE_BY: Bayern
  # DE_HB: Bremen
  # DE_HE: Hessen
  # DE_HH: Hamburg
  # DE_MV: Mecklenburg-Vorpommern
  # DE_NI: Niedersachsen
  # DE_NW: Nordrhein-Westfalen
  # DE_RP: Rheinland-Pfalz
  # DE_SH: Schleswig-Holstein
  # DE_SL: Saarland
  # DE_SN: Sachsen
  # DE_ST: Sachsen-Anhalt
  # DE_TH: Thüringen
  STATES = []
  ['DE'].each_with_object({}) do |country, o|
    ISO3166::Country.new(country).subdivisions.keys.each do |c|
      val = "#{country}_#{c}"
      o[val] = val
      STATES << val
    end
  end.tap do |states|
    enum state: states
  end
  # DE_BB, DE_BE, DE_BW, DE_BY, ...
  STATES.freeze

  def self.filter(value)
    do_filter(value, :city, :street, :zip)
  end
end
