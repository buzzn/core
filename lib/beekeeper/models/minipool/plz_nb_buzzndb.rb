# == Schema Information
#
# Table name: minipooldb.plz_nb_buzzndb
#
#  plz            :integer
#  ort            :string(300)
#  verbandsnummer :string(45)
#

class Beekeeper::Minipool::PlzNbBuzzndb < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.plz_nb_buzzndb'

end
