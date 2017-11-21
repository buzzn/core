# == Schema Information
#
# Table name: buzzndb.used_plz_sn
#
#  ix       :integer          not null, primary key
#  plz      :string(10)
#  kwh      :string(10)
#  datetime :datetime
#

class Beekeeper::Buzzn::UsedPlzSn < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.used_plz_sn'
end
