# == Schema Information
#
# Table name: minipooldb.msb_gerät
#
#  vertragsnummer            :integer          not null
#  nummernzusatz             :integer          not null
#  lcpvertragsnummer         :integer          not null
#  zählernummer              :string(45)       not null
#  zpid                      :string(45)       not null
#  adresszusatz              :string(45)       not null
#  sparte                    :string(45)       not null
#  zählpunktTyp              :string(45)       not null
#  anzahlverbzp              :integer          not null
#  anzahlZähler              :integer          not null
#  spannungsebene            :string(45)       not null
#  geplturnusables           :string(16)
#  turnusintervall           :string(25)       not null
#  zuständigerMSB            :string(25)       not null
#  versandarbeitvnb          :string(10)       not null
#  berechneterZähler         :string(10)       not null
#  vnb                       :string(45)       not null
#  vnbmpid                   :string(25)       not null
#  msb                       :string(45)       not null
#  msbmpid                   :string(25)       not null
#  mdl                       :string(45)       not null
#  mdlmpid                   :string(25)       not null
#  lieferant                 :string(45)       not null
#  lieferantmpid             :string(25)       not null
#  zählerHersteller          :string(45)       not null
#  zählerTyp                 :string(25)       not null
#  zählerBesitz              :string(25)       not null
#  zählerZählertyp           :string(35)       not null
#  zählerGröße               :string(25)       not null
#  zählerFernauslesung       :string(10)       not null
#  discovergybenutzer        :string(60)       not null
#  discovergypasswort        :string(300)      not null
#  elsterablageort           :string(300)      not null
#  tarif                     :string(25)       not null
#  richtung                  :string(45)       not null
#  messwerterfassung         :string(45)       not null
#  befestigungsart           :string(45)       not null
#  zählerBaujahr             :string(10)       not null
#  zählerGeeichtBis          :string(16)
#  zählerHerstellerNr        :string(35)       not null
#  zusatz1Geräteart          :string(45)       not null
#  zusatz1wandlerfaktor      :string(45)       not null
#  zusatz1hersteller         :string(45)       not null
#  zusatz1baujahr            :string(45)       not null
#  zusatz1typ                :string(45)       not null
#  zusatz1geeichtbis         :string(16)
#  zusatz1besitz             :string(45)       not null
#  zusatz1herstellernr       :string(45)       not null
#  zusatz2Geräteart          :string(45)       not null
#  zusatz2hersteller         :string(45)       not null
#  zusatz2baujahr            :string(45)       not null
#  zusatz2typ                :string(45)       not null
#  zusatz2geeichtbis         :string(16)
#  zusatz2besitz             :string(45)       not null
#  zusatz2herstellernr       :string(45)       not null
#  berechnetbeschreibungkurz :string(45)       not null
#  berechnetbeschreibunglang :string(1000)     not null
#  berechnetformelklar       :string(1000)     not null
#  berechnetformelexcel      :string(1000)     not null
#  zpideinspeis              :string(40)       not null
#

class Beekeeper::Minipool::MsbGerät < Beekeeper::Minipool::BaseRecord
  self.table_name = 'minipooldb.msb_gerät'
end
