# == Schema Information
#
# Table name: buzzndb.plz_to_sn_price
#
#  plz              :string(6)
#  whole_price_year :string(10)
#  av_price         :float
#  gp_dt            :float
#  ap_dt            :float
#  msb_dt           :float
#  gp_et            :float
#  ap_et            :float
#  msb_et           :float
#  ka               :float
#  bundesland       :string(20)
#  city             :string(30)
#  vdew_code        :string(12)
#

class Beekeeper::Buzzn::PlzToSnPrice < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.plz_to_sn_price'

end
