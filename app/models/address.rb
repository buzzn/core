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

  def self.filter(value)
    do_filter(value, :city, :street, :zip)
  end

  def to_s
    "#{street}, #{zip} #{city}"
  end
end
