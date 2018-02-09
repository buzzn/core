# == Schema Information
#
# Table name: minipooldb.nne_vnb_buzzndb
#
#  verbandsnummer :string(15)       not null, primary key
#  typ            :string(10)
#  messung_et     :float
#  abrechnung_et  :float
#  zaehler_et     :float
#  mp_et          :float
#  messung_dt     :float
#  abrechnung_dt  :float
#  zaehler_dt     :float
#  mp_dt          :float
#  arbeitspreis   :float
#  grundpreis     :float
#  vorlaeufig     :string(8)
#

class Beekeeper::Minipool::NneVnbBuzzndb < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.nne_vnb_buzzndb'

end
