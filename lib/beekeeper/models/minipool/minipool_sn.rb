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

  def converted_attributes
    {
      contract_number:          vertragsnummer,
      contract_number_addition: nummernzusatz,
      forecast_kwh_pa:          prognose_verbrauch.to_i,
      powertaker:               powertaker,
      signing_date:             begin_date,
      begin_date:               begin_date,
      termination_date:         end_date,
      end_date:                 end_date,
      # register:                 register
    }
  end

  delegate :person?, to: :kontaktdaten

  private

  #
  # WIP, but I may throw this away again.
  #
  # WARNING: this way of getting the register is quite fragile.
  # The Beekeeper::MeterRegistry is only filled when add_registers has run before this method, which it does
  # in the _current_ order of the import.
  # def register
  #   meter = Beekeeper::MeterRegistry.get(buzznid.strip)
  #   ap meter
  #   if meter
  #     puts "METER"
  #     meter.registers.first
  #   else
  #     puts "ELSE"
  #     add_warning("contract register", "No meter found for buzznid #{buzznid}; imported contract has no register now.")
  #     # For now, return a fake register so the import continues
  #     Register::Input.new(name: "Fake temporary register for import")
  #     # nil
  #   end
  # end

  # this will be extended to return a new organization once we add those to the import
  def powertaker
    @powertaker ||= ::Person.new(kontaktdaten.converted_attributes)
  end

  def kontaktdaten
    @kontaktdaten ||= Beekeeper::Minipool::Kontaktdaten.find_by(kontaktdaten_id: kontakt_id)
  end

  def begin_date
    Date.parse(bezugsbeginn)
  end

  def end_date
    Date.parse(bezugsende)
  end

  def eeg_umlage_reduced?
    eeg_umlage == "-1"
  end
end
