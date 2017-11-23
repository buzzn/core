# == Schema Information
#
# Table name: buzzndb.plz_to_sn_price_2018
#
#  plz              :string(6)
#  whole_price_year :string(10)
#  av_price         :float
#  gp2017_dt        :float
#  ap2017_dt        :float
#  msb2017_dt       :float
#  gp2017_et        :float
#  ap2017_et        :float
#  msb2017_et       :float
#  ka               :float
#  bundesland       :string(20)
#  city             :string(30)
#  vdew_code        :string(12)
#

class Beekeeper::Buzzn::PlzToSnPrice2018 < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.plz_to_sn_price_2018'
end
