class MeteringPointDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all
  decorates_association :devices
  decorates_association :meter
  decorates_association :users
  decorates_association :location
  decorates_association :group
  decorates_association :electricity_supplier_contracts
  decorates_association :metering_service_provider_contracts
  decorates_association :metering_point_operator_contracts
  decorates_association :distribution_system_operator_contracts
  decorates_association :transmission_system_operator_contracts


  def thumb_small
    link_to image_tag_small, model, :data => { 'toggle' => 'tooltip', container: 'body', 'original-title' => name }, rel: 'tooltip'
  end

  def image_tag_small
    content_tag(:i, '', class: 'fa fa-map-marker')
  end

  def thumb_medium
    link_to image_tag_medium, model
  end

  def image_tag_medium
    content_tag(:i, '', class: 'fa fa-map-marker')
  end

  def image_tag_sm
    content_tag(:i, '', class: 'fa fa-map-marker')
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



  def name
    case mode
    when 'in'
      address_addition
    when 'in_out'
      "#{t(mode)} #{generator_type_names}-#{address_addition}"
    when 'out'
      "#{t(mode)} #{generator_type_names} #{address_addition}"
    end
  end


  def generator_type_names
    names = []
    generator_types = devices.map {|i| i.generator_type }.uniq
    generator_types.each do |type|
      names << t("#{type}_short") if type
    end
    return names.join(', ')
  end





  def link_to_show
    link_to model.name, metering_point_path(model)
  end


  def link_to_edit
    link_to(
      raw(content_tag(:i, '', class: 'fa fa-cog') + t('edit')),
      edit_metering_point_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-icon btn-danger btn-xs',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end


  def new_register
    link_to(
      t("add_register"),
      new_register_path(metering_point_id: model.id),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end


  def new_device
    if model.output?
      path = new_out_device_path(metering_point_id: model.id)
    else
      path = new_in_device_path(metering_point_id: model.id)
    end
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle'),
      path,
      {
        :remote       => true,
        :class        => 'sidebar-plus',
        'data-toggle' => 'modal',
        'data-target' => '#myModal',
      })
  end



  def edit_users
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle'),
      edit_users_metering_point_path(model),
      {
        :remote       => true,
        :class        => 'sidebar-plus',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

  def edit_devices
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle'),
      edit_devices_metering_point_path(model),
      {
        :remote       => true,
        :class        => 'sidebar-plus',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

  def new_metering_point_operator_contract
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle') + '  ' + t("add_metering_point_operator_contract"),
      new_metering_point_operator_contract_path(metering_point_id: model.id),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end


  def new_meter
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle'),
      new_meter_path(metering_point_id: model.id),
      {
        :remote       => true,
        :class        => 'content-plus',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end



end
