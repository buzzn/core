module Beekeeper
  module StringCleaner

    def clean_string(string, downcase: false)
      return if string.blank? # blank covers nil, "", " ", "  ", ...
      string.strip!
      downcase ? string.downcase : string
    end

  end
end
