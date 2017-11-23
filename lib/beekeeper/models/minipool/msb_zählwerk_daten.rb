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

class Beekeeper::Minipool::MsbZählwerkDaten < Beekeeper::Minipool::BaseRecord
  self.table_name = 'minipooldb.msb_zählwerk_daten'

  def converted_attributes
    {
      name:             kennzeichnung,
      low_load_ability: false,
      obis:             obis,
      type:             map_type,
      label:            map_label
    }
  end

  def register_nr
    "#{vertragsnummer}/#{nummernzusatz}"
  end

  private

  def obis
    return '1-1:1.8.0' if ['1-1:1.8.0', "1-1:.8.0"].include?(read_attribute(:obis))
    return '1-1:2.8.0' if ['1-1:2.8.0', '1-1:2:8.0'].include?(read_attribute(:obis))
    raise "Unknown obis: #{self[:obis]}"
  end

  def kennzeichnung
    read_attribute(:kennzeichnung).strip
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

  # Not used right now
  # def pool
  #   @pool ||= Beekeeper::MinipoolObjekte.find_by(messvertragsnummer: vertragsnummer)
  # end
end
