# == Schema Information
#
# Table name: buzzndb.zstand
#
#  idsz_stand     :integer          not null, primary key
#  marktplatz_id  :integer
#  einspeisung_nt :float
#  einspeisung_ht :float
#  quelle         :string(45)
#  grund          :string(45)
#  datum          :string(16)
#  timestamp      :string(32)
#  art            :string(20)
#

class Beekeeper::Buzzn::Zstand < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.zstand'
end
