# == Schema Information
#
# Table name: buzzndb.slps
#
#  datetime          :datetime         not null
#  9900496000005_BAN :float            not null
#  9900496000005_G5  :float            not null
#  9900496000005_G6  :float            not null
#  9900496000005_H0  :float            not null
#  9900496000005_L0  :float            not null
#  9900496000005_L1  :float            not null
#  9900496000005_L2  :float            not null
#  9900496000005_SB1 :float            not null
#  9900496000005_SB2 :float            not null
#  9900496000005_SP  :float            not null
#  9900496000005_WP0 :float            not null
#  9900496000005_ES0 :float            not null
#  9900496000005_EW0 :float            not null
#  9900496000005_EY0 :float            not null
#  9900496000005_G0  :float            not null
#  9900496000005_G1  :float            not null
#  9900496000005_G2  :float            not null
#  9900496000005_G3  :float            not null
#  9900496000005_G4  :float            not null
#  9901000000001_E21 :float            not null
#  9901000000001_H21 :float            not null
#  9901000000001_D21 :float            not null
#  9901000000001_L21 :float            not null
#  9901000000001_B21 :float            not null
#  9901000000001_G21 :float            not null
#

class Beekeeper::Buzzn::Slps < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.slps'
end
