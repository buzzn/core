require 'smarter_csv'

module Converters
  class Date
    def self.convert(value)
      ::Date.strptime(value, '%m/%d/%y') # parses custom date format into Date instance
    end
  end
  class Number
    def self.convert(value)
      value.gsub('.', '').to_i
    end
  end
  class PreferredLanguage
    def self.convert(value)
      { 'DE' => :german, 'EN' => :english }[value]
    end
  end
  class Boolean
    def self.convert(value)
      return true if %w(1 true wahr WAHR).include?(value)
      return false if %w(0 false falsch FALSCH).include?(value)
      raise "Unexpected value #{value} for boolean column"
    end
  end
  class Downcase
    def self.convert(value)
      value&.downcase
    end
  end
  class MeterManufacturerName
    def self.convert(value)
      value == "EasyMeter GmbH" ? "easy_meter" : "other"
    end
  end
end

def import_csv(model_name, converters: {}, fields: [], overrides: {}, dry_run: false)
  file_name = Rails.root.join("db/sample_data/#{model_name}.csv")
  hashes = SmarterCSV.process(file_name,
    col_sep: ";",
    convert_values_to_numeric: false,
    value_converters: converters
  )
  puts "\n* #{model_name.to_s.capitalize}"
  hashes.each do |hash|
    fabricator     = "new_#{model_name.to_s.singularize}".to_sym
    attributes     = hash.slice(*fields).merge(overrides)
    attributes_str = attributes.map do |k, v|
      v = v.is_a?(Numeric) ? v : "'#{v}'"
      "#{k}: #{v}"
    end.join(", ")
    puts "Fabricate(:#{fabricator}, #{attributes_str})"
    Fabricate(fabricator, attributes) unless dry_run
  end
end
