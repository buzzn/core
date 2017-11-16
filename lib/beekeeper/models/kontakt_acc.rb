# == Schema Information
#
# Table name: minipooldb.kontakt_acc
#
#  marktplatz_id   :integer
#  vorname         :string(45)
#  nachname        :string(45)
#  strasse         :string(45)
#  plz             :string(6)
#  stadt           :string(45)
#  bundesland      :string(45)
#  email           :string(45)
#  telefon         :string(45)
#  typ             :string(45)
#  status          :string(45)
#  produkt         :string(25)
#  geschlecht      :string(45)
#  anrede          :string(45)
#  titel           :string(45)
#  briefanrede     :string(45)
#  email2          :string(45)
#  bestätigung     :string(45)
#  hausnummer      :string(6)
#  account_selbst  :string(6)
#  timestamp       :string(32)
#  fibunr          :integer          not null, primary key
#  photo_vorhanden :string(1)
#

class Beekeeper::KontaktAcc < Beekeeper::BaseRecord
  self.table_name = 'minipooldb.kontakt_acc'
end
