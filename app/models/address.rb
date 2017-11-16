class Address < ActiveRecord::Base

  # germany: 'DE'
  # austria: 'AT'
  # switzerland: 'CH'
  # ...
  ISO3166::Country.all.tap do |countries|
    map = countries.each_with_object({}) do |country, object|
      object[country.name.gsub(/[().,]/,'').gsub(/ /, '_').downcase] = country.alpha2
    end
    enum country: map
  end

  # brandenburg:            DE_BB
  # berlin:                 DE_BE
  # baden_württemberg:      DE_BW
  # bayern:                 DE_BY
  # bremen:                 DE_HB
  # hessen:                 DE_HE
  # hamburg:                DE_HH
  # mecklenburg_vorpommern: DE_MV
  # niedersachsen:          DE_NI
  # nordrhein_westfalen:    DE_NW
  # rheinland_pfalz:        DE_RP
  # schleswig_holstein:     DE_SH
  # saarland:               DE_SL
  # sachsen:                DE_SN
  # sachsen_anhalt:         DE_ST
  # thüringen:              DE_TH
  ['DE'].tap do |country|
    map = country.each_with_object({}) do |country, object|
      ISO3166::Country.new(country).subdivisions.each do |key, value|
        new_key = value.name.sub(/-/, '_').downcase
        object[new_key] = "#{country}_#{key}"
      end
    end
    enum state: map
  end

  def self.filter(value)
    do_filter(value, :city, :street, :zip)
  end
end
