# == Schema Information
#
# Table name: minipooldb.minipool_objekte
#
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

  belongs_to :adresse, foreign_key: 'adress_id'

  scope :to_import, -> { where("minipool_start != '0000-00-00'") }

  # attr_accessor :distribution_system_operator, :transmission_system_operator, :electricity_supplier

  def converted_attributes
    {
      name: name,
      start_date: start_date,
      distribution_system_operator: distribution_system_operator,
      transmission_system_operator: transmission_system_operator,
      electricity_supplier:         electricity_supplier,
      address:                      address,
      owner:                        owner
    }
  end

  ORG_NAME_TO_SLUG_MAP = {
    "Bayernwerk"               => 'bayernwerk-netz',
    "Bayernwerke"              => 'bayernwerk-netz',
    "Bayernwerk AG"            => 'bayernwerk-netz',
    "E.dis AG"                 => 'e-dis',
    "Gemeindewerke Peißenberg" => 'gemeindewerke-peissenberg',
    "LEW"                      => 'lew',
    "NEW Netz"                 => 'new-netz',
    "SWM"                      => 'swm-infrastruktur',
    "Stadtwerke München"       => 'swm-infrastruktur',
    "M-Strom business Garant"  => 'swm-versorgung',
    "M-Ökostrom"               => 'swm-versorgung',
    "Stadtwerke Landshut"      => 'sw-landshut',
    "Stadtwerke Schorndorf"    => 'sw-schorndorf',
    "Stadtwerke Waiblingen"    => 'sw-waiblingen',
    "Syna"                     => 'syna',
    "Syna GmbH"                => 'syna',
    "bnNetze"                  => 'bn-netze',
    "buzzn"                    => 'buzzn',
    "Lichtblick"               => 'lichtblick',
    # Orgs still to be created in the core app
    "SW Netz GmbH"             => 'sw-wiesbaden',
    "Netz Leipzig"             => 'netz-leipzig',
    "BEG Freising"             => 'sw-freising',
    "Hamburg Netz"             => 'stromnetz-hamburg',
    'Vattenfall'               => 'stromnetz-berlin',
    'Stromnetz Berlin'         => 'stromnetz-berlin',
  }

  def distribution_system_operator
    slug = ORG_NAME_TO_SLUG_MAP.fetch(netzbetreiber.strip, "MISSING")
    org_for_slug(slug, netzbetreiber, :distribution_system_operator)
  end

  def transmission_system_operator
    slug = case uenb
      when /a(m)?prion/i then 'amprion'
      when /tennet/i     then 'tennet'
      when /50 hertz/i   then '50hertz'
      when /Transnet( )?BW/ then 'transnetbw'
      else
        # nothing to do, org_for_slug will print a warning if org not found.
    end
    org_for_slug(slug, uenb, :transmission_system_operator)
  end

  def electricity_supplier
    slug = ORG_NAME_TO_SLUG_MAP.fetch(reststromlieferant.strip, "MISSING")
    org_for_slug(slug, reststromlieferant, :electricity_supplier)
  end

  def start_date
    Date.parse(minipool_start)
  end

  def name
    minipool_name.strip
  end

  def address
    Address.new(adresse.converted_attributes)
  end

  def owner
    if account_new.privat1_gbr2_weg3_else4 == 'privat'
      owner_person
    else
      owner_organization
    end
  end

  private

  def starts_in_future?
    start_date > Date.today
  end

  def owner_person
    Person.new(kontakt_acc.converted_attributes(bank_accounts))
  end

  def owner_organization
    nil
  end

  def account_new
    Beekeeper::Buzzn::AccountNew.find(vertragskontonummer)
  end

  def kontakt_acc
    Beekeeper::Buzzn::KontaktAcc.find(vertragskontonummer)
  end

  def bank_accounts
    konto = Beekeeper::Minipool::Kontodaten.where(vertragsnummer: vertragsnummer, nummernzusatz: 0).first
    [BankAccount.new(konto.converted_attributes)]
  rescue Buzzn::RecordNotFound => e
    logger.warn("#{name}: unable to find bank data: #{e.message}}")
    []
  end

  def logger
    @logger ||= Buzzn::Logger.new(self)
  end

  def org_for_slug(slug, beekeeper_value, lookup_purpose)
    org = Organization.find_by(slug: slug)
    if !org && !starts_in_future?
      logger.warn("#{name}: unable to map #{lookup_purpose}. Beekeeper value is '#{beekeeper_value}'.")
    end
    org
  end
end
