# == Schema Information
#
# Table name: buzzndb.plz_vnb
#
#  plz            :integer
#  ort            :string(90)
#  verbandsnummer :string(45)
#  name           :string(90)
#

class Beekeeper::Buzzn::PlzVnb < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.plz_vnb'

end
