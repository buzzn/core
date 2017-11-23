# == Schema Information
#
# Table name: buzzndb.sn_user_data
#
#  idsn                       :integer
#  marktplatz_id              :integer
#  fibunr                     :integer
#  vorname                    :string(45)
#  nachname                   :string(40)
#  strasse_bs                 :string(45)
#  hausnummer_bs              :string(45)
#  zusatz                     :string(45)
#  stadt_bs                   :string(25)
#  bundesland_bs              :string(40)
#  plz_bs                     :string(11)
#  land_bs                    :string(20)
#  vertretung_1ok_0nok        :string(11)
#  einspeiseort_hier1_anders0 :string(10)
#  einziehen_1neu_0alt        :string(10)
#  zaehlernummer              :string(45)
#  zaehlpunktid               :string(45)
#  stromlieferant_alt         :string(45)
#  kundennummer_alt           :string(45)
#  vertragskontonummer_alt    :string(45)
#  tag_erstbelieferung        :string(45)
#  stromverbrauch_bisher      :float
#  abschlagzahlung_bisher     :float
#  slp                        :string(20)
#  kommentar                  :text
#  timestamp                  :string(32)
#  photo_vorhanden            :string(1)
#  netzbetreiber              :string(50)
#  uenb                       :string(20)
#  kontoinhaber               :string(40)
#  kontonummer                :string(40)
#  blz                        :string(40)
#  kreditinstitut             :string(45)
#  schonbeihall               :string(1)
#  bezugsende                 :string(45)
#  title                      :string(20)
#  gis_lat                    :float
#  gis_lon                    :float
#  status                     :string(30)
#  iban                       :string(40)       not null
#  bic                        :string(40)       not null
#  mandatsnr                  :string(40)       not null
#  messart                    :string(20)
#  vertragsdatum              :string(16)       not null
#  stromverbrauch_einzug      :string(1000)     not null
#  messstellenbetreiber       :string(100)      not null
#  zaehlertyp                 :string(25)       not null
#  red_ka                     :string(1)
#  localpool                  :string(1)
#  tarif                      :string(30)
#  vorauss_monatsp            :float
#  nutzung                    :string(15)
#  msb_id                     :string(10)       not null
#

class Beekeeper::Buzzn::SnUserData < Beekeeper::Buzzn::BaseRecord
  self.table_name = 'buzzndb.sn_user_data'
end
