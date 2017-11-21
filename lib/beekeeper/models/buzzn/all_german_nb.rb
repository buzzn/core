# == Schema Information
#
# Table name: buzzndb.all_german_nb
#
#  mpid                :string(13)
#  name                :string(64)
#  ilincode            :string(13)
#  snbetreibernr       :string(13)
#  bilanzierungsgebiet :string(19)
#  vnb_bilanz_gebiet   :string(63)
#  valid_beginn        :string(12)
#  valid_ende          :string(10)
#  aenderungsdatum     :string(15)
#  rz                  :string(16)
#

class Beekeeper::Buzzn::AllGermanNb < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.all_german_nb'
end
