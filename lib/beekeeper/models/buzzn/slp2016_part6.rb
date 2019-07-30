# == Schema Information
#
# Table name: buzzndb.slp2016_part6
#
#  datetime          :datetime
#  4045458000000_BET :float            not null
#  4045458000000_BFE :float            not null
#  4045458000000_KLA :float            not null
#  4045458000000_KWK :float            not null
#  4045458000000_WAS :float            not null
#  4045458000000_WAT :float            not null
#  4045458000000_WIN :float            not null
#  4045458000000_BFL :float            not null
#  4045458000000_BGF :float            not null
#  4045458000000_BGT :float            not null
#  4045458000000_DEP :float            not null
#  4045458000000_GEO :float            not null
#  4045458000000_GET :float            not null
#  4045458000000_GRU :float            not null
#  4045458000000_KGT :float            not null
#  9900207000004_G0  :float            not null
#  9900401000008_AG5 :float            not null
#  9907240000009_L0  :float            not null
#  9907240000009_L2  :float            not null
#

class Beekeeper::Buzzn::Slp2016Part6 < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.slp2016_part6'

end
