# coding: utf-8
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
  include Beekeeper::ImportWarnings

  def converted_attributes
    {
      contract_number:               vertragsnummer,
      contract_number_addition:      nummernzusatz,
      forecast_kwh_pa:               prognose_verbrauch.to_i,
      powertaker:                    powertaker,
      signing_date:                  begin_date,
      begin_date:                    begin_date,
      termination_date:              termination_date,
      end_date:                      end_date,
      buzznid:                       buzznid.strip,
      old_supplier_name:             vorlieferant&.strip,
      old_customer_number:           kundennummer_alt&.strip,
      old_account_number:            vertragskontonummer_alt&.strip,
      third_party_renter_number:     mieternummer&.strip,
      third_party_billing_number:    rechnungsnummer&.strip,
      renewable_energy_law_taxation: renewable_energy_law_taxation,
      payments:                      payments,
      paid_payments:                 paid_payments,
    }
  end

  delegate :person?, to: :kontaktdaten

  private

  def powertaker
    # always return a new, unsaved record. The duplicates from Beekeeper will be removed later on,
    # when the records and localpool are saved.
    @powertaker ||= if kontaktdaten.person?
                      Person.new(kontaktdaten.converted_attributes.merge(address: address))
    else
      Organization::General.new(kontaktdaten.converted_attributes.merge(address: address))
    end
  end

  def renewable_energy_law_taxation
    case eeg_umlage
    when '1'
      :full
    when '-1'
      :reduced
    else
      :null
    end
  end

  def address
    ::Address.new(Beekeeper::Minipool::Adresse.find_by(adress_id: adress_id).converted_attributes)
  end

  def kontaktdaten
    @kontaktdaten ||= Beekeeper::Minipool::Kontaktdaten.find_by(kontaktdaten_id: kontakt_id)
  end

  def begin_date
    Date.parse(bezugsbeginn)
  end

  # Even if the contract is not terminated, beekeeper sets an end date (2050-01-01 or later).
  # So only if the end_date is earlier than 2050-01-01, we take it seriously and import it.
  def end_date
    end_date = Date.parse(bezugsende)
    end_date < Date.parse('2050-01-01') ? end_date : nil
  end

  def termination_date
    (end_date && (end_date <= Date.today)) ? end_date : nil
  end

  def eeg_umlage_reduced?
    eeg_umlage == '-1'
  end

  def payments
    Beekeeper::Minipool::Abschlag.where(vertragsnummer: vertragsnummer, nummernzusatz: nummernzusatz).to_a.collect(&:converted_attributes)
  end

  def paid_payments
    Beekeeper::Minipool::AbschlagVergleich.where(vertragsnummer: vertragsnummer, nummernzusatz: nummernzusatz).to_a.collect(&:converted_attributes)
  end

end
