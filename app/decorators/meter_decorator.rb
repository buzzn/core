class MeterDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def link_to_edit
    if model.virtual_registers.any?
      metering_point_id = model.virtual_registers.first.metering_point.id
    else
      metering_point_id = model.registers.first.metering_point.id
    end
    link_to(
      t('edit'),
      edit_meter_path(model, :metering_point_id => metering_point_id),
      {
        remote: true,
        class: 'start_modal btn btn-danger pull-right',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

end