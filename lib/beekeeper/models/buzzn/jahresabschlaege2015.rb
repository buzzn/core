# == Schema Information
#
# Table name: buzzndb.jahresabschlaege2015
#
#  vertragsnummer :string(6)
#  vertragskonto  :string(6)
#  betrag         :float
#  bemerkung      :string(120)
#  datum          :string(10)
#

class Beekeeper::Buzzn::Jahresabschlaege2015 < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.jahresabschlaege2015'
end
