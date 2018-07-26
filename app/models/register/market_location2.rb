#
# "Marktlokation" is a term defined in German energy legislation, see for details:
# https://de.wikipedia.org/wiki/Marktlokations-Identifikationsnummer
#
module Register
  class MarketLocation2 < ActiveRecord::Base

    # TODO self.table_name = 'market_locations'
    self.table_name = 'market_locations2'

    has_many :meta, class_name: 'Meta'

  end
end
