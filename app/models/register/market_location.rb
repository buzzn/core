#
# "Marktlokation" is a term defined in German energy legislation, see for details:
# https://de.wikipedia.org/wiki/Marktlokations-Identifikationsnummer
#
module Register
  class MarketLocation < ActiveRecord::Base

    self.table_name = 'market_locations'

    has_many :meta, class_name: 'Meta'

  end
end
