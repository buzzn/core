# == Schema Information
#
# Table name: minipooldb.minipool_sn
#
#  vertragsnummer          :integer          not null
#  nummernzusatz           :integer          not null
#  vertragspartner         :string(40)       not null
#  adress_id               :integer          not null
#  zaehlernummer           :string(40)       not null
#  zaehlpunkt_id           :string(40)       not null
#  vorlieferant            :string(45)       not null
#  kundennummer_alt        :string(20)       not null
#  vertragskontonummer_alt :string(20)       not null
#  umzug                   :integer          not null
#  bezugsbeginn            :string(16)
#  bezugsende              :string(16)
#  status                  :string(45)       not null
#  adress_id_bezug         :integer          not null
#  erstbelieferung         :string(16)
#  zaehlerstand            :float            not null
#  prognose_verbrauch      :float            not null
#  vollmacht               :integer          not null
#  verbrauch_vorjahr       :float            not null
#  abschlag_bisher         :float            not null
#  kontakt_id              :integer          not null
#  vertragskontonummer     :integer          not null
#  drittbelieferung        :integer          not null
#  eeg_umlage              :string(2)        not null
#  rechnungsnummer         :string(25)       not null
#  buzznid                 :string(10)       not null
#  mieternummer            :string(25)       not null
#

class Beekeeper::Minipool::MinipoolSn < Beekeeper::Minipool::BaseRecord
  self.table_name = 'minipooldb.minipool_sn'

  def eeg_umlage_reduced?
    eeg_umlage == "-1"
  end
end
