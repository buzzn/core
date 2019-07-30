# == Schema Information
#
# Table name: buzzndb.cnt_mscons_vl
#
#  cnt       :integer          not null, primary key
#  bdew_to   :string(15)
#  timestamp :string(32)
#

class Beekeeper::Buzzn::CntMsconsVl < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.cnt_mscons_vl'

end
