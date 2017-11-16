# == Schema Information
#
# Table name: minipooldb.konto
#
#  marktplatz_id   :integer          not null, primary key
#  produkt         :string(45)
#  kontoinhaber    :string(45)
#  kontonummer     :string(45)
#  blz             :string(11)
#  kreditinstitut  :string(45)
#  unternehmer_ja1 :string(40)
#  umsatzsteuerid  :string(45)
#  steuersatz      :string(15)
#  steuernummer    :string(45)
#  fibunr          :integer
#  einzugserm      :string(3)
#  erstelldatum    :datetime
#

class Beekeeper::Konto < Beekeeper::BaseRecord
  self.table_name = 'minipooldb.konto'
end
