class MeterDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :registers
  decorates_association :metering_point

  def name
    "#{manufacturer_name} #{manufacturer_product_serialnumber}"
  end


  def link_to_edit
    link_to(
      t('edit'),
      edit_meter_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-rounded btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end


  def link_to_new
    metering_point_id = model.registers.first.metering_point.id
    link_to(
      t('new'),
      new_meter_path(model, :metering_point_id => metering_point_id),
      {
        remote: true,
        class: 'start_modal btn btn-primary btn-rounded btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end




  def new_register
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_register_path(meter_id: model.id),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_register"),
      })
  end




end