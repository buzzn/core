# == Schema Information
#
# Table name: minipooldb.plz_nb
#
#  plz            :integer
#  ort            :string(300)
#  verbandsnummer :string(45)
#

class Beekeeper::PlzNb < Beekeeper::BaseRecord
  self.table_name = 'minipooldb.plz_nb'
end
