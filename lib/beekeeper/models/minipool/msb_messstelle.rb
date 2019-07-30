# == Schema Information
#
# Table name: minipooldb.msb_messstelle
#
#  vertragsnummer      :integer          not null, primary key
#  vertragskontonummer :integer          not null
#  kundenname          :string(70)       not null
#  start               :string(16)
#  masterzpid          :string(40)       not null
#  strasse1            :string(45)       not null
#  strasse2            :string(45)       not null
#  hausnummer1         :string(5)        not null
#  hausnummer2         :string(5)        not null
#  adresszusatz1       :string(25)       not null
#  adresszusatz2       :string(25)       not null
#  plz                 :string(10)       not null
#  ort                 :string(45)       not null
#  anzahlerz           :integer          not null
#  anzahlzrz           :integer          not null
#  anzahlrlm           :integer          not null
#  anzahlberechnet     :integer          not null
#  erznetto            :float            not null
#  zrznetto            :float            not null
#  rlmnetto            :float            not null
#  berechnetnetto      :float            not null
#  summenetto          :float            not null
#  kontoinhaber        :string(45)       not null
#  iban                :string(45)       not null
#  bic                 :string(25)       not null
#  kreditinstitut      :string(45)       not null
#  sgvertrag           :integer          not null
#  snvertrag           :integer          not null
#  lcpvertrag          :integer          not null
#  einzugsermächtigung :string(1)
#  masterzpid2         :string(40)       not null
#

class Beekeeper::Minipool::MsbMessstelle < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.msb_messstelle'

end
