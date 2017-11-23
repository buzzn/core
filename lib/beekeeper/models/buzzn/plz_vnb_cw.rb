# == Schema Information
#
# Table name: buzzndb.plz_vnb_cw
#
#  plz            :integer
#  ort            :string(300)
#  verbandsnummer :string(45)
#

class Beekeeper::Buzzn::PlzVnbCw < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.plz_vnb_cw'
end
