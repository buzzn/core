# == Schema Information
#
# Table name: minipooldb.abschlag
#
#  id_arbeit      :integer          not null, primary key
#  vertragsnummer :integer          not null
#  nummernzusatz  :integer          not null
#  arbeit         :integer          not null
#  abschlag       :float            not null
#  datum          :string(16)       not null
#  timestamp      :string(32)       not null
#  bezugspreis    :integer          not null
#

class Beekeeper::Minipool::Abschlag < Beekeeper::Minipool::BaseRecord
  self.table_name = 'minipooldb.abschlag'
end
