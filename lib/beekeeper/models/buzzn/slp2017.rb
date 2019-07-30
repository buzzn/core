# == Schema Information
#
# Table name: buzzndb.slp2017
#
#  datetime          :datetime
#  9900027000002_G00 :float            not null
#  9900027000002_L00 :float            not null
#  9900027000002_B00 :float            not null
#  9900027000002_WI0 :float            not null
#  9900027000002_KL0 :float            not null
#  9900027000002_DE0 :float            not null
#  9900027000002_BI0 :float            not null
#  9900027000002_KW0 :float            not null
#  9900027000002_WA0 :float            not null
#  9900153000009_B0  :float            not null
#  9900153000009_G0  :float            not null
#  9900153000009_G3  :float            not null
#  9900153000009_H0  :float            not null
#  9900153000009_G4  :float            not null
#  9900202000009_OB1 :float            not null
#  9900202000009_OG1 :float            not null
#  9900202000009_OH1 :float            not null
#  9900202000009_OL1 :float            not null
#  9900396000006_G0  :float            not null
#  9900396000006_G4  :float            not null
#  9900396000006_L0  :float            not null
#  9900396000006_G3  :float            not null
#  9900396000006_L1  :float            not null
#  9900396000006_L2  :float            not null
#  9900770000002_BAN :float            not null
#  9900770000002_EBN :float            not null
#

class Beekeeper::Buzzn::Slp2017 < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.slp2017'

end
