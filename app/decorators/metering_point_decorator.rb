class MeteringPointDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all
  decorates_association :devices
  decorates_association :meter
  decorates_association :users

  def title
    if name && name != ''
      name
    else
      long_name
    end
  end

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

  def link_to_show
    link_to title, metering_point_path(model)
  end

  def link_to_edit
    link_to(
      title,
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
    if model.up?
      path = new_up_device_path(metering_point_id: model.id)
    else
      path = new_down_device_path(metering_point_id: model.id)
    end
    link_to(
      '',
      path,
      {
        :remote       => true,
        :class        => 'start_modal glyphicon glyphicon-plus-sign',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end



  def edit_users
    link_to(
      '',
      edit_users_metering_point_path(model),
      {
        :remote       => true,
        :class        => 'start_modal glyphicon glyphicon-plus-sign',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end






  def long_name
    case model.mode
    when 'up'
      "#{model.position}. #{t(model.mode)} #{t('for')} #{generator_type_names}-#{model.address_addition}"
    when 'down'
      "#{model.position}. #{t(model.mode)} - #{model.address_addition}"
    when 'up_down'
      "#{model.position}. #{t(model.mode)}"
    when 'diff'
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
