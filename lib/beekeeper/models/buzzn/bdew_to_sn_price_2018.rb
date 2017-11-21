# == Schema Information
#
# Table name: buzzndb.bdew_to_sn_price_2018
#
#  bdew          :string(12)
#  namevnb       :string(40)
#  msb_et        :float
#  abrechnung_et :float
#  zaehler_et    :float
#  mp_et         :float
#  msb_dt        :float
#  abrechnung_dt :float
#  zaehler_dt    :float
#  mp_dt         :float
#  gueltig_ab    :datetime
#  ap            :float
#  gp            :float
#  vorlaeufig    :string(6)
#

class Beekeeper::Buzzn::BdewToSnPrice2018 < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.bdew_to_sn_price_2018'
end
