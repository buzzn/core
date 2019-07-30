# == Schema Information
#
# Table name: minipooldb.zstand
#
#  idsz_stand     :integer          not null, primary key
#  vertragsnummer :integer          not null
#  nummernzusatz  :integer          not null
#  zaehlernummer  :string(35)       not null
#  einspeisung_ht :float            not null
#  quelle         :string(45)       not null
#  grund          :string(45)       not null
#  datum          :string(16)       not null
#  timestamp      :string(32)       not null
#  summe          :float            not null
#  unterschied    :float            not null
#  art            :string(20)       not null
#

class Beekeeper::Minipool::Zstand < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.zstand'

end
