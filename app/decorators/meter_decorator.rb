class MeterDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def link_to_edit
    link_to(
      t('edit'),
      edit_meter_path(model, :metering_point_id => model.registers.first.metering_point.id),
      {
        remote: true,
        class: 'start_modal btn btn-danger pull-right',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

end