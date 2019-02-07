# coding: utf-8

require_relative 'concerns/import_warnings'
require_relative 'concerns/minipool_objekte/organizations'
require_relative 'concerns/minipool_objekte/owner'
require_relative 'concerns/minipool_objekte/registers'
require_relative 'concerns/minipool_objekte/powertaker_contracts'
require_relative 'concerns/minipool_objekte/abschlag_information'

# == Schema Information
#
# Table name: minipooldb.minipool_objekte
#
# Abwicklungsvertrag Nummer
#  vertragsnummer                   :integer          not null
#  nummernzusatz                    :integer          not null
#  objekttyp                        :string(20)       not null
#  netzbetreiber                    :string(100)      not null
#  anzahl_parteien                  :integer          not null
#  bezug_parteien                   :float            not null
#  anzahl_belieferung               :integer          not null
#  bezug_belieferung                :float            not null
#  gesetz                           :string(30)       not null
#  hersteller                       :string(30)       not null
#  leistung                         :float            not null
#  typ                              :string(30)       not null
#  inbetriebnahme                   :string(16)
#  primaerenergie                   :string(20)       not null
#  jahresstromerzeugung             :float            not null
#  zweirichtung_exist               :integer          not null
#  zweirichtung_strom               :integer          not null
#  zweirichtung_lieferant           :string(40)       not null
#  adress_id                        :integer          not null
#  adress_id_kontakt                :integer          not null
#  sg_vertragsnummer                :integer          not null
#  sn_vertragsnummer                :integer          not null
# Messvertrags Nummer
#  messvertragsnummer               :integer          not null
#  vertragskontonummer              :integer          not null
#  kontaktdaten_id                  :integer          not null
#  nachricht_buzzn                  :string(500)      not null
#  aufmerksam_durch                 :string(100)      not null
#  eigenverbrauch                   :string(20)       not null
#  minipool_name                    :string(100)      not null
#  minipool_start                   :string(16)
#  reststrombezug                   :integer          not null
#  strom_mit_eeg                    :integer          not null
#  strom_ohne_eeg                   :integer          not null
#  strom_drittbeliefert             :integer          not null
#  strom_eeg_pflicht                :float            not null
#  uenb                             :string(50)       not null
#  anzahl_lsn                       :integer          not null
#  sea_1_buzznid                    :string(15)       not null
#  sea_2_buzznid                    :string(15)       not null
#  sea_3_buzznid                    :string(15)       not null
#  sea_4_buzznid                    :string(15)       not null
#  sea_1_energieträger              :string(25)       not null
#  sea_2_energieträger              :string(25)       not null
#  sea_3_energieträger              :string(25)       not null
#  sea_4_energieträger              :string(25)       not null
#  bezug_buzznid                    :string(15)       not null
#  einspeis_buzznid                 :string(15)       not null
#  reststromlieferant               :string(55)       not null
#  strom_reduziert_eeg              :integer          not null
#  automat_abschlag_anp             :integer
#  automat_abschlag_anp_schwellwert :integer          default(5), not null
#  red_eeg_satz                     :float            default(40.0), not null
#

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord

  self.table_name = 'minipooldb.minipool_objekte'
  self.primary_key = 'vertragsnummer'

  include Beekeeper::Minipool::MinipoolObjekte::Organizations
  include Beekeeper::Minipool::MinipoolObjekte::Owner
  include Beekeeper::Minipool::MinipoolObjekte::Registers
  include Beekeeper::Minipool::MinipoolObjekte::PowertakerContracts
  include Beekeeper::Minipool::MinipoolObjekte::AbschlagInformation

  belongs_to :adresse, foreign_key: 'adress_id'

  scope :to_import, -> { where("minipool_start != '0000-00-00'").order(:minipool_start, :minipool_name) }

  def converted_attributes
    @converted_attributes ||= {
      name: name,
      start_date: start_date,
      processing_contract_number: vertragsnummer,
      processing_contract_number_addition: nummernzusatz,
      metering_contract_number: messvertragsnummer,
      show_display_app:             show_display_app,
      distribution_system_operator: distribution_system_operator,
      transmission_system_operator: transmission_system_operator,
      electricity_supplier:         electricity_supplier,
      address:                      address,
      owner:                        owner,
      bank_account:                 bank_accounts.first,
      registers:                    registers,
      powertaker_contracts:         powertaker_contracts,
      third_party_contracts:        third_party_contracts,
      tariffs:                      tariffs,
      legacy_power_giver_contract_buzznid: einspeis_buzznid,
      legacy_power_taker_contract_buzznid: bezug_buzznid,
      billing_detail:               billing_detail
    }
  end

  def name
    minipool_name.strip
  end

  private

  # these are the meters
  def msb_geräte
    @_msb_geräte ||= Beekeeper::Minipool::MsbGerät.where(vertragsnummer: messvertragsnummer)
  end

  # these are the registers
  def msb_zählwerk_daten
    @_msb_zählwerk_daten ||= Beekeeper::Minipool::MsbZählwerkDaten.where(vertragsnummer: messvertragsnummer)
  end

  def start_date
    Date.parse(minipool_start)
  end

  GROUPS_WITH_DISPLAY_APP_ENABLED = [
    'Green warriors (Testgruppe)',
    'People Power Group (Testgruppe)',
  ]

  def show_display_app
    GROUPS_WITH_DISPLAY_APP_ENABLED.include?(minipool_name)
  end

  def address
    Address.new(adresse.converted_attributes)
  end

  def tariffs
    Beekeeper::Minipool::MinipoolPreise.where(vertragsnummer: vertragsnummer).order(datum: :desc).collect do |preise|
      preise.converted_attributes
    end.reverse.to_enum.with_index(1) do |attributes, index|
      attributes[:name] = "Tarif #{index}"
    end
  end

end
