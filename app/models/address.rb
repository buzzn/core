class Address < ActiveRecord::Base

  # germany: 'DE'
  # austria: 'AT'
  # switzerland: 'CH'
  # ...
  ISO3166::Country.all.each_with_object({}) do |c, o|
    o[c.name.gsub(/[().,]/,'').gsub(/ /, '_').downcase] = c.alpha2
  end.tap do |map|
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
  ['DE'].each_with_object({}) do |country, o|
    ISO3166::Country.new(country).subdivisions.each do |key, value|
      val = "#{country}_#{key}"
      o[value.name.sub(/-/, '_').downcase] = val
    end
  end.tap do |states|
    enum state: states
  end

  def self.filter(value)
    do_filter(value, :city, :street, :zip)
  end
end
