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
      # TODO consider removing obis from DB, it can be derived from the type of register and is meaningless for virtual registers.
      obis:                  obis,
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
      low_load_ability:      false              # always (string) "ZNS - Nicht schwachlastfähig"
    }
  end

  def identifier
    "#{vertragsnummer}/#{nummernzusatz}/#{zählwerkID} (name: #{read_attribute(:name)})"
  end

  def msb_gerät
    @_msb_gerät ||= Beekeeper::Minipool::MsbGerät.find_by(vertragsnummer: vertragsnummer, nummernzusatz: nummernzusatz)
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

  # TODO clarify if every register must be named, right now it isn't (see MISSING).
  # TODO define sensible constraints for the name. Right now we have everything from "7" to names longer than 40 chars.
  def name
    stripped = msb_gerät.adresszusatz.strip
    if stripped.empty?
      add_warning(:name, "Missing name for #{identifier}")
      "MISSING"
    else
      stripped
    end
  end

  def obis_input?
    obis == '1-1:1.8.0'
  end

  def obis_output?
    obis == '1-1:2.8.0'
  end

  def map_type
    return 'Register::Input' if obis_input?
    return 'Register::Output' if obis_output?
  end

  def map_label
    return 'PRODUCTION_PV' if is_pv_production_register?
    return 'PRODUCTION_CHP' if is_chp_production_register?

    return 'DEMARCATION_PV' if is_pv_demarcation_register?
    return 'DEMARCATION_CHP' if is_chp_demarcation_register?

    return 'GRID_CONSUMPTION' if is_grid_consumption_register?
    return 'GRID_FEEDING' if is_grid_feeding_register?
    return 'CONSUMPTION' if is_feeding_register?
    return 'OTHER' if is_other_register?
    raise "Unknown label: #{kennzeichnung.inspect}"
  end

  def is_feeding_register?
    kennzeichnung == 'Bezug'
  end

  def is_other_register?
    kennzeichnung == 'Sonstige'
  end

  def is_grid_consumption_register?
    kennzeichnung == 'ÜGZ Bezug'
    # Data is inconsistent, using the label instead
    #pool && (pool.bezug_buzznid == register_nr) && map_type == 'Register::Input'
  end

  def is_grid_feeding_register?
    kennzeichnung == 'ÜGZ Einspeisung'
    # Data is inconsistent, using the label instead
    # pool && (pool.bezug_buzznid == register_nr) && map_type == 'Register::Output'
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

  # Not used right now
  # def register_nr
  #   "#{vertragsnummer}/#{nummernzusatz}"
  # end

  # Not used right now
  # def pool
  #   @pool ||= Beekeeper::MinipoolObjekte.find_by(messvertragsnummer: vertragsnummer)
  # end
  #
  #
  def logger
    @logger ||= Buzzn::Logger.new(self)
  end
end
