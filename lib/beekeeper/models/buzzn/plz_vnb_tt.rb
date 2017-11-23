# == Schema Information
#
# Table name: buzzndb.plz_vnb_tt
#
#  plz            :integer
#  ort            :string(90)
#  verbandsnummer :string(18)
#  name           :string(90)
#

class Beekeeper::Buzzn::PlzVnbTt < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.plz_vnb_tt'
end
