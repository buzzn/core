# == Schema Information
#
# Table name: buzzndb.arbeit_soll
#
#  id_arbeit      :integer          not null, primary key
#  marktplatz_id  :integer
#  arbeit_soll    :float
#  arbeit_ist     :float
#  abschlag       :float
#  einspeisepreis :float
#  datum          :string(16)
#  timestamp      :string(32)
#

class Beekeeper::Buzzn::ArbeitSoll < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.arbeit_soll'
end
