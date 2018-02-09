# == Schema Information
#
# Table name: buzzndb.jahresarbeit_sg
#
#  id              :integer          not null, primary key
#  vertragsnummer  :integer
#  jahr            :integer
#  ist_einspeisung :float
#

class Beekeeper::Buzzn::JahresarbeitSg < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.jahresarbeit_sg'

end
