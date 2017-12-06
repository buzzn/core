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

# these are the meters
class Beekeeper::Minipool::MsbGerät < Beekeeper::Minipool::BaseRecord
  self.table_name = 'minipooldb.msb_gerät'
  self.primary_key = 'vertragsnummer'

  include Beekeeper::ImportWarnings

  def converted_attributes
    @converted_attributes ||= {
      product_serialnumber:   zählernummer.strip,
      product_name:           zählerTyp.strip,
      build_year:             zählerBaujahr.strip,
      converter_constant:     zusatz1wandlerfaktor.strip,
      manufacturer_name:      manufacturer_name,
      manufacturer_description: manufacturer_description,
      ownership:              ownership,
      direction_number:       direction_number,
      calibrated_until:       calibrated_until,
      sequence_number:        nummernzusatz,
      edifact_voltage_level:  edifact_voltage_level,
      edifact_cycle_interval: edifact_cycle_interval,
      edifact_metering_type:  edifact_metering_type,
      edifact_meter_size:     edifact_meter_size,
      edifact_data_logging:   edifact_data_logging,
      edifact_tariff:         edifact_tariff,
      edifact_measurement_method: edifact_measurement_method,
      edifact_mounting_method: edifact_mounting_method,
      buzznid:                 buzznid
    }
  end

  def buzznid
    "#{vertragsnummer}/#{nummernzusatz}"
  end

  # used directly from MsbZählwerkDaten
  def metering_point_id
    stripped = zpid.strip
    stripped == "" ? nil : stripped
  end

  def virtual?
    regex = /vi(r)?t/i # match the variations "virt.", "virtuell" and "vituell", case insensitive
    fields_to_check = %i(zählernummer adresszusatz zählerHersteller zählerTyp berechnetbeschreibungkurz)
    fields_to_check.any? { |field| send(field) =~ regex }
  end

  def msb_zählwerke
    @_msb_zählwerke ||= Beekeeper::Minipool::MsbZählwerkDaten.where(vertragsnummer: vertragsnummer, nummernzusatz: nummernzusatz)
  end

  private

  def edifact_voltage_level
    default_value = Meter::Real.edifact_voltage_levels[:low_level]
    map_edifact_enum(:spannungsebene, :edifact_voltage_level, default: default_value)
  end

  def edifact_cycle_interval
    # we only have these two values
    return "YEARLY"  if turnusintervall.strip == "jährlich"
    return "MONTHLY" if turnusintervall.strip == "monatlich"
    add_warning(:turnusintervall, %(invalid edifact_cycle_interval "#{turnusintervall.strip}" for zählernummer #{zählernummer}))
    nil
  end

  def edifact_metering_type
    # SM (smart meter) is an identifier that doesn't exist in edifact, but we know that it needs to
    # be mapped to EHZ (Elektronischer Haushaltszähler)
    if zählerZählertyp =~ /^SM/
      'EHZ'
    else
      map_edifact_enum(:zählerZählertyp, :edifact_metering_type)
    end
  end

  def edifact_meter_size
    # We know most of our meters are easymeters, and all of them are Z03, so we set that as default
    # so PhO doesn't have to update 660 records manually.
    map_edifact_enum(:zählerGröße, :edifact_meter_size, default: :other_ehz)
  end

  def edifact_data_logging
    return "Z05" if zählerFernauslesung.strip == "Ja"
    return "Z04" if zählerFernauslesung.strip == "Nein"
    add_warning(:zählerFernauslesung, %(invalid edifact_data_logging "#{zählerFernauslesung.strip}" for zählernummer #{zählernummer}))
    nil
  end

  def edifact_tariff
    map_edifact_enum(:tarif, :edifact_tariff)
  end

  def edifact_measurement_method
    map_edifact_enum(:messwerterfassung, :edifact_measurement_method)
  end

  def edifact_mounting_method
    map_edifact_enum(:befestigungsart, :edifact_mounting_method, default: :three_point_mounting)
  end

  def calibrated_until
    Date.parse(zählerGeeichtBis.strip)
  rescue ArgumentError
    add_warning(:zählerGeeichtBis, %(invalid calibrated_until date "#{zählerGeeichtBis.strip}" for zählernummer #{zählernummer}))
    nil
  end

  # TODO when manufacturer isn't easymeter, add the manufacturer name to a (new) description attribute
  def manufacturer_name
    if zählerHersteller =~ /easymeter/i
      'easy_meter'
    else
      'other'
    end
  end

  def manufacturer_description
    # If the manufacturer is easymeter, everything is in manufacturer_name and product_name.
    # If the field zählerHersteller is not empty, we store it in manufacturer_description.
    if manufacturer_name == 'easy_meter' || zählerHersteller.strip.empty?
      nil
    else
      zählerHersteller
    end
  end

  OWNERSHIP_MAPPING = {
    'Eigenturm bM' => 'BUZZN',
    'Fremdbesitz'  => 'FOREIGN_OWNERSHIP',
    'Kunde'        => 'CUSTOMER',
    'gepachtet'    => 'LEASED',
    'gekauft'      => 'BOUGHT'
  }

  def ownership
    OWNERSHIP_MAPPING.fetch(zählerBesitz.strip)
  rescue KeyError
    add_warning(:zählerBesitz, %(unknown ownership for value "#{zählerBesitz}" for zählernummer #{zählernummer}))
    nil
  end

  def direction_number
    return 'ERZ' if richtung =~ /^ERZ/
    return 'ZRZ' if richtung =~ /^ZRZ/
    add_warning(:richtung, %(unknown direction for value "#{richtung}" for zählernummer #{zählernummer}))
    nil
  end

  #
  # beekeeper stores the values for a few edifact attributes like this:
  #
  # ETZ - Eintarif
  # SM - smart Meter
  # ...
  #
  # This method parses the first capitalized letters (and numbers) and returns that if it a value we know.
  #
  def map_edifact_enum(beekeeper_name, our_name, default: nil)
    known_values    = Meter::Real.send(our_name.to_s.pluralize).values # uses our enum
    extracted_value = send(beekeeper_name).strip.scan(/^[A-Z0-9]+/).first
    if known_values.include?(extracted_value)
      extracted_value
    elsif default
      default
    else
      add_warning(beekeeper_name, %(invalid #{our_name} "#{extracted_value}" for zählernummer #{zählernummer}))
      nil
    end
  end
end
