# == Schema Information
#
# Table name: minipooldb.kontaktdaten
#
#  kontaktdaten_id :integer          not null, primary key
#  anrede          :string(20)       not null
#  titel           :string(20)       not null
#  geschlecht      :string(10)       not null
#  vorname         :string(40)       not null
#  nachname        :string(100)      not null
#  firma           :string(40)       not null
#  vertretung      :integer          not null
#  telefon         :string(20)       not null
#  fax             :string(20)       not null
#  email           :string(80)       not null
#  mobil           :string(20)       not null
#  rechtsform      :string(20)       not null
#

class Beekeeper::Minipool::Kontaktdaten < Beekeeper::Minipool::BaseRecord
  self.table_name = 'minipooldb.kontaktdaten'
end
