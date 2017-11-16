# == Schema Information
#
# Table name: minipooldb.msb_zählwerk_zst
#
#  vertragsnummer  :integer          not null
#  nummernzusatz   :integer          not null
#  zählwerkID      :integer          not null
#  ablesezeitpunkt :string(16)
#  messwert        :float            not null
#  ablesegrund     :string(60)       not null
#  qualitaet       :string(60)       not null
#  ableser         :string(25)       not null
#  zaehlernummer   :string(45)       not null
#  statuszst       :string(45)       not null
#  id              :integer          not null, primary key
#

class Beekeeper::MsbZählwerkZst < Beekeeper::BaseRecord
  self.table_name = 'minipooldb.msb_zählwerk_zst'
end
