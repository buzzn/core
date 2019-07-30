# == Schema Information
#
# Table name: buzzndb.kommentare_ac
#
#  fibunr    :integer          not null
#  kommentar :string(1000)     not null
#  autor     :string(30)       not null
#  datum     :string(32)       not null
#

class Beekeeper::Buzzn::KommentareAc < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.kommentare_ac'

end
