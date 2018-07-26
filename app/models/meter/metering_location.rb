#
# "Messlokation" is a term defined in German energy legislation, see for details:
# https://de.wikipedia.org/wiki/Marktlokations-Identifikationsnummer#Messlokation
#
module Meter
  class MeteringLocation < ActiveRecord::Base

    self.table_name = 'metering_locations'

    has_many :meters, class_name: 'Real'

  end
end
