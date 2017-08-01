if Rails.env == "production" || Rails.env == "staging"
  class Address

    after_validation :geocode
    geocoded_by :geocoding_name
    
    def geocoding_name
      [ street, city, zip, state, country].compact.join(', ')
    end
  end
end
