class RegisterDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :metering_point

  def panel_mode_class
    case model.mode
    when 'in'
      'primary'
    when 'out'
      'danger'
    end
  end

  def name
    t(model.mode)
  end

  def link_to_edit
    link_to(
      t('edit'),
      edit_register_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-rounded btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

  def last_two_readings
    latest_readings = Reading.last_two_by_register_id(model.id)
    if latest_readings.nil?
      return nil
    end
    result = []
    result.push(latest_readings.first[:timestamp].to_i*1000)
    result.push(latest_readings.first[:watt_hour])
    result.push(latest_readings.last[:timestamp].to_i*1000)
    result.push(latest_readings.last[:watt_hour])
    return result
  end




end