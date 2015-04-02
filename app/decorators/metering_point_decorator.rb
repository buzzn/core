class MeteringPointDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all
  decorates_association :devices
  decorates_association :address
  decorates_association :meter
  decorates_association :users
  decorates_association :location
  decorates_association :group
  decorates_association :contracts
  decorates_association :electricity_supplier_contracts
  decorates_association :metering_service_provider_contracts
  decorates_association :metering_point_operator_contracts
  decorates_association :distribution_system_operator_contracts
  decorates_association :transmission_system_operator_contracts


  def smart_image
    if model.image?
      return model.image
    elsif model.devices.any?
      return model.devices.first.image
    end
  end


  def mode_class
    case model.mode
    when 'in'
      'primary'
    when 'out'
      'danger'
    end
  end


  def long_name
    if model.address
       "#{model.name} (#{model.address.street_name})"
    else
      model.name
    end
  end


  def link_to_delete
    link_to(
      t('delete'),
      model,
      remote: false,
      class: 'btn btn-danger',
      :method => :delete,
      :data => {
        :confirm => t('are_you_sure')
    })
  end




  def generator_type_names
    names = []
    generator_types = devices.map {|i| i.category }.uniq
    generator_types.each do |type|
      names << type if type
    end
    return names.join(', ')
  end





  def link_to_edit
    link_to(
      t('edit'),
      edit_metering_point_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-rounded btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end



  def edit_devices
    link_to(
      content_tag(:i, t("add_or_remove_devices"), class: 'btn btn-default btn-rounded btn-labeled fa fa-link'),
      edit_devices_metering_point_path(model),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal'
      })
  end


  def edit_users
    link_to(
      content_tag(:i, t("add_or_remove_members"), class: 'btn btn-default btn-rounded btn-labeled fa fa-link'),
      edit_users_metering_point_path(model),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal'
      })
  end


  def new_address
    link_to(
      content_tag(:i, t("create_address"), class: 'btn btn-default btn-rounded btn-labeled fa fa-plus'),
      new_address_path(addressable_id: model.id, addressable_type: 'MeteringPoint'),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal'
      })
  end



  def new_meter
    link_to(
      content_tag(:i, t("create_meter"), class: 'btn btn-default btn-rounded btn-labeled fa fa-plus'),
      new_meter_path(metering_point_id: model.id),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal'
      })
  end


  def new_contract
    link_to(
      content_tag(:i, t("create_contract"), class: 'btn btn-default btn-rounded btn-labeled fa fa-plus'),
      new_contract_path(metering_point_id: model.id),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal'
      })
  end

  def add_to_dashboard
    link_to(
      content_tag(:i, t("add_to_dashboard"), class: 'btn btn-default btn-rounded btn-labeled fa fa-link'),
      add_metering_point_dashboard_path(metering_point_id: model.id, slug: current_user.dashboard.slug),
      {
        :remote         => true,
      })
  end

  def remove_from_dashboard
    link_to(
      content_tag(:i, t("remove_from_dashboard"), class: 'btn btn-default btn-rounded btn-labeled fa fa-link'),
      remove_metering_point_dashboard_path(metering_point_id: model.id, slug: current_user.dashboard.slug),
      {
        :remote         => true,
      })
  end

  def display_in_series
    link_to(
      content_tag(:i, t("display_in_series"), class: 'btn btn-default btn-rounded btn-labeled fa fa-link'),
      display_metering_point_in_series_dashboard_path(metering_point_id: model.id, slug: current_user.dashboard.slug, operator: "+", series: 1),
      {
        :remote         => true,
      })
  end




end
