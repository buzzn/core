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
    {
      name:                  name,
      type:                  map_type,
      label:                 map_label,
      meter:                 meter,
      metering_point_id:     metering_point_id,
      # set these defaults (not imported from beekeeper)
      share_with_group:      false,
      share_publicly:        false,
      # TODO the following are always the same, consider removing
      pre_decimal_position:  vorkommastellen,   # always 6
      post_decimal_position: nachkommastellen,  # always 1
      low_load_ability:      false,              # always (string) "ZNS - Nicht schwachlastfähig"
      # TODO consider removing obis from DB, it can be derived from the type of register and is meaningless for virtual registers.
      obis:                  obis,
    }
  end

  def identifier
    "#{vertragsnummer}/#{nummernzusatz}/#{zählwerkID} (name: #{read_attribute(:name)})"
  end

  def msb_gerät
    @_msb_gerät ||= Beekeeper::Minipool::MsbGerät.find_by(vertragsnummer: vertragsnummer, nummernzusatz: nummernzusatz)
  end

  def skip_import?
    virtual? || msb_gerät.virtual?
  end

  private

  # FIXME right now every new register creates a new meter
  def meter
    @_meter ||= Meter::Real.new(msb_gerät.converted_attributes)
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

  def map_label
    return 'PRODUCTION_PV' if is_pv_production_register?
    return 'PRODUCTION_CHP' if is_chp_production_register?

    return 'DEMARCATION_PV' if is_pv_demarcation_register?
    return 'DEMARCATION_CHP' if is_chp_demarcation_register?

    return 'GRID_CONSUMPTION' if is_grid_consumption_register?
    return 'GRID_FEEDING' if is_grid_feeding_register?
    return 'CONSUMPTION' if is_feeding_register?
    # TODO map CONSUMPTION_COMMON:
    # 1. join with minipool_sn using "#{messtellenvertrag}/#{nummernzusatz}" and buzznid
    # 2. if eeg_umlage == -1 => CONSUMPTION_COMMON
    return 'OTHER' if is_other_register?
    add_warning(:label, "Unknown label: #{kennzeichnung.inspect}")
  end

  def is_feeding_register?
    kennzeichnung == 'Bezug'
  end

  def is_other_register?
    kennzeichnung == 'Sonstige'
  end

  def is_grid_consumption_register?
    kennzeichnung == 'ÜGZ Bezug'
  end

  def is_grid_feeding_register?
    kennzeichnung == 'ÜGZ Einspeisung'
  end

  def is_pv_production_register?
    kennzeichnung == 'PV Produktion'
  end

  def is_chp_production_register?
    kennzeichnung == 'BHKW Produktion'
  end

  def is_pv_demarcation_register?
    kennzeichnung == 'PV Abgrenzung'
  end

  def is_chp_demarcation_register?
    kennzeichnung == 'BHKW Abgrenzung'
  end

  def kennzeichnung
    read_attribute(:kennzeichnung).strip
  end

  def virtual?
    kennzeichnung =~ /Abgrenzung/i
  end
end
