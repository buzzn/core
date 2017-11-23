# == Schema Information
#
# Table name: buzzndb.kommentare_nb
#
#  fullname  :string(50)       not null
#  kommentar :string(1000)     not null
#  autor     :string(30)       not null
#  datum     :string(32)       not null
#

class Beekeeper::Buzzn::KommentareNb < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.kommentare_nb'
end
