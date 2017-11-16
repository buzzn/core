# == Schema Information
#
# Table name: minipooldb.zaehler
#
#  vertragsnummer :integer          not null
#  nummernzusatz  :integer          not null
#  zaehlertyp     :string(20)       not null
#  zaehler        :string(10)       not null
#  zaehlernummer  :string(15)       not null
#  zaehlpunktid   :string(33)       not null
#

class Beekeeper::Zaehler < ActiveRecord::Base
  self.table_name = 'minipooldb.zaehler'
end
