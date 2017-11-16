# == Schema Information
#
# Table name: minipooldb.plz_nb
#
#  plz            :integer
#  ort            :string(300)
#  verbandsnummer :string(45)
#

class Beekeeper::PlzNb < ActiveRecord::Base
  self.table_name = 'minipooldb.plz_nb'
end
