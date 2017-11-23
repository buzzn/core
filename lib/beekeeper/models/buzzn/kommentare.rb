# == Schema Information
#
# Table name: buzzndb.kommentare
#
#  typ           :string(2)        not null
#  marktplatz_id :integer          not null
#  kommentar     :string(1000)     not null
#  autor         :string(25)       not null
#  datum         :string(32)       not null
#

class Beekeeper::Buzzn::Kommentare < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.kommentare'
end
