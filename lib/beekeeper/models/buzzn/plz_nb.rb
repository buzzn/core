# == Schema Information
#
# Table name: buzzndb.plz_nb
#
#  plz            :integer
#  ort            :string(300)
#  verbandsnummer :string(45)
#

class Beekeeper::Buzzn::PlzNb < Beekeeper::Buzzn::BaseRecord

  self.table_name = 'buzzndb.plz_nb'

end
