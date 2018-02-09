# == Schema Information
#
# Table name: minipooldb.kommentare_nb
#
#  fullname  :string(50)       not null
#  kommentar :string(1000)     not null
#  autor     :string(30)       not null
#  datum     :string(32)       not null
#

class Beekeeper::Minipool::KommentareNb < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.kommentare_nb'

end
