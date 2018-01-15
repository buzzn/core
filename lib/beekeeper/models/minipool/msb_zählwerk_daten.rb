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
      readings:              readings,
      # set these defaults (not imported from beekeeper)
      share_with_group:      false,
      share_publicly:        false
    }
  end

  def buzznid
    "#{vertragsnummer}/#{nummernzusatz}"
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

  def obis
    return '1-1:1.8.0' if ['1-1:1.8.0', "1-1:.8.0"].include?(read_attribute(:obis))
    return '1-1:2.8.0' if ['1-1:2.8.0', '1-1:2:8.0'].include?(read_attribute(:obis))
    add_warning(:obis, "Unknown obis: #{read_attribute(:obis)} for #{buzznid}")
  end

  private

  def meter_attributes
    msb_gerät.converted_attributes
  end

  def name
    stripped = msb_gerät.adresszusatz.strip
    if stripped.empty?
      add_warning(:name, "Missing name for #{buzznid}")
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
    label = refine_consumption_label   if label == 'CONSUMPTION'
    label = refine_production_pv_label if label == 'PRODUCTION_PV'
    # puts "#{kennzeichnung} #{msb_gerät.adresszusatz} => #{label}"
    add_warning(:label, "Unknown label: #{kennzeichnung.inspect}") unless label
    label
  end

  def refine_consumption_label
    if name_hints_at_common_register? || input_register_of_group_power_source?
      'CONSUMPTION_COMMON'
    else
      'CONSUMPTION'
    end
  end

  def refine_production_pv_label
    # Am Urtlgraben has water.
    return 'PRODUCTION_WATER' if msb_gerät.adresszusatz =~ /Wasser/
    # Fritz-Winter-Straße has wind.
    return 'PRODUCTION_WIND' if msb_gerät.adresszusatz =~ /Kleinwindrad/
    'PRODUCTION_PV'
  end

  # Power production sources often have a two-way meter, one for their own power consumption and one for generation.
  # This methods checks if we are such a register.
  def input_register_of_group_power_source?
    input? && group_power_source_buzznids.include?(buzznid)
  end

  # Labels of common consumption meters are inconsistent: "Allg.", "Gemeinschaft", ....
  def name_hints_at_common_register?
    pattern = /(allg|gemein|Aufzug|Heiz|E-Tankstelle|ladestation|Haustechnik|Antenne|Gem EG|UV E-Bikes E-Raum|Hausstrom)/i
    name =~ pattern && name !~ /Bürogemeinschaft/
  end

  def group_power_source_buzznids
    group_seas = group.attributes.slice("sea_1_buzznid", "sea_2_buzznid", "sea_3_buzznid").values
    group_seas.select(&:present?)
  end

  def group
    @group ||= Beekeeper::Minipool::MinipoolObjekte.find_by(messvertragsnummer: vertragsnummer)
  end

  def readings
    readings = Beekeeper::Minipool::MsbZählwerkZst.where(vertragsnummer: vertragsnummer, nummernzusatz: nummernzusatz, zählwerkID: zählwerkID).to_a
    uniq_readings = readings.uniq { |r| [r[:ablesezeitpunkt], r[:ablesegrund]] }

    unless uniq_readings.length == readings.length
      dups = readings.group_by { |r| [r[:ablesezeitpunkt], r[:ablesegrund]] }.select { |_, r| r.length > 1 }
      dups.each do |_, dup_arr|
        dup_arr.each do |dup|
          add_warning(:readings, "duplicate for: vertragsnummer: #{dup.vertragsnummer}, nummernzusatz: #{dup.nummernzusatz}, zählwerkID: #{dup.zählwerkID}, date: #{dup.ablesezeitpunkt}")
        end
      end
    end

    uniq_readings.map { |r| Reading::Single.new(r.converted_attributes) }
  end
end
