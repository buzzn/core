# == Schema Information
#
# Table name: minipooldb.msb_zählwerk_daten
#
#  vertragsnummer   :integer          not null
#  nummernzusatz    :integer          not null
#  zählwerkID       :integer          not null
#  obis             :string(10)       not null
#  kennzeichnung    :string(45)       not null
#  schwachlastfähig :string(45)       not null
#  vorkommastellen  :integer          not null
#  nachkommastellen :integer          not null
#

# these are the actual registers
class Beekeeper::Minipool::MsbZählwerkDaten < Beekeeper::Minipool::BaseRecord
  self.table_name = 'minipooldb.msb_zählwerk_daten'
  self.primary_key = 'vertragsnummer'

  include Beekeeper::ImportWarnings
  delegate :metering_point_id, to: :msb_gerät

  def converted_attributes
    @converted_attributes ||= {
      meter_attributes:      meter_attributes,
      name:                  name,
      type:                  map_type,
      label:                 map_label,
      metering_point_id:     metering_point_id,
      # set these defaults (not imported from beekeeper)
      share_with_group:      false,
      share_publicly:        false,
      # TODO the following are always the same, consider removing
      pre_decimal_position:  vorkommastellen,   # always 6
      post_decimal_position: nachkommastellen,  # always 1
      low_load_ability:      false,              # always (string) "ZNS - Nicht schwachlastfähig"
      # TODO consider removing obis from DB, it can be derived from the type of register and is meaningless for virtual registers.
      obis:                  obis
    }
  end

  def buzznid
    "#{vertragsnummer}/#{nummernzusatz}"
  end

  def identifier
    "#{vertragsnummer}/#{nummernzusatz}/#{zählwerkID} (name: #{read_attribute(:name)})"
  end

  def msb_gerät
    @_msb_gerät ||= Beekeeper::Minipool::MsbGerät.find_by(vertragsnummer: vertragsnummer, nummernzusatz: nummernzusatz)
  end

  def minipool_sn
    @minipool_sn ||= Beekeeper::Minipool::MinipoolSn.find_by(buzznid: "#{vertragsnummer}/#{nummernzusatz}")
  end

  def skip_import?
    msb_gerät.virtual?
  end

  def kennzeichnung
    read_attribute(:kennzeichnung).strip
  end

  private

  def meter_attributes
    msb_gerät.converted_attributes
  end

  def obis
    return '1-1:1.8.0' if ['1-1:1.8.0', "1-1:.8.0"].include?(read_attribute(:obis))
    return '1-1:2.8.0' if ['1-1:2.8.0', '1-1:2:8.0'].include?(read_attribute(:obis))
    add_warning(:obis, "Unknown obis: #{read_attribute(:obis)} for #{identifier}")
  end

  def name
    stripped = msb_gerät.adresszusatz.strip
    if stripped.empty?
      add_warning(:name, "Missing name for #{identifier}")
      "MISSING"
    else
      stripped
    end
  end

  def input?
    obis == '1-1:1.8.0'
  end

  def output?
    obis == '1-1:2.8.0'
  end

  def map_type
    return 'Register::Input' if input?
    return 'Register::Output' if output?
  end

  LABEL_MAP = {
    'Bezug'           => 'CONSUMPTION',
    'Sonstige'        => 'OTHER',
    'PV Produktion'   => 'PRODUCTION_PV',
    'BHKW Produktion' => 'PRODUCTION_CHP',
    'PV Abgrenzung'   => 'DEMARCATION_PV',
    'BHKW Abgrenzung' => 'DEMARCATION_CHP',
    'ÜGZ Bezug'       => 'GRID_CONSUMPTION',
    'ÜGZ Einspeisung' => 'GRID_FEEDING',
  }

  def map_label
    label = LABEL_MAP[kennzeichnung]
    if label == 'CONSUMPTION' && minipool_sn&.eeg_umlage_reduced?
      label = 'CONSUMPTION_COMMON'
    end
    if kennzeichnung == "PV Produktion" && msb_gerät.adresszusatz =~ /Wasser/
      label = 'PRODUCTION_WATER'
    end
    # puts "#{kennzeichnung} #{msb_gerät.adresszusatz} => #{label}"
    add_warning(:label, "Unknown label: #{kennzeichnung.inspect}") unless label
    label
  end
end
