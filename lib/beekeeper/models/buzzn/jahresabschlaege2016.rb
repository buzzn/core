# == Schema Information
#
# Table name: buzzndb.jahresabschlaege2016
#
#  vertragsnummer :string(6)
#  vertragskonto  :string(6)
#  betrag         :float
#  bemerkung      :string(120)
#  datum          :string(10)
#

class Beekeeper::Buzzn::Jahresabschlaege2016 < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.jahresabschlaege2016'

end
