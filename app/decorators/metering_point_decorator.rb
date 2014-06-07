class MeteringPointDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all
  decorates_association :meter
  decorates_association :devices


  def link_to_delete
    link_to(
      t('delete'),
      model,
      remote: true,
      class: 'btn btn-danger',
      :method => :delete,
      :data => {
        :confirm => t('are_you_sure')
      })
  end


  def link_to_edit
    link_to(
      name,
      edit_metering_point_path(model),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end


  def new_meter
    link_to(
      t("add_meter"),
      new_meter_path(metering_point_id: model.id),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end




  def new_device
    if model.up_metering?
      path = new_up_device_path(metering_point_id: model.id)
    else
      path = new_down_device_path(metering_point_id: model.id)
    end
    link_to(
      t("add_device"),
      path,
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end




  def name
    case model.mode
    when 'up_metering'
      "#{model.position}. #{t(model.mode)} #{t('for')} #{generator_type_names}-#{model.address_addition}"
    when 'down_metering'
      "#{model.position}. #{t(model.mode)} - #{model.address_addition}"
    when 'up_down_metering'
      "#{model.position}. #{t(model.mode)}"
    when 'diff_metering'
      "#{model.position}. #{t(model.mode)}"
    else
      "no mode"
    end
  end

  def generator_type_names
    names = []
    generator_types = model.devices.map {|i| i.generator_type }.uniq
    generator_types.each do |type|
      names << t("#{type}_short")
    end
    return names.join(', ')
  end

end
