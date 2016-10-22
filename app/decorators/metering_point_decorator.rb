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
  decorates_association :power_giver_contracts
  decorates_association :power_taker_contracts
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

  def picture(size=nil)
    if model.image.present?
      if size == 'lg'
        image_tag model.image.lg, class: 'img-lg img-circle img-user media-object', alt: ""
      elsif size == 'md'
        image_tag model.image.md, class: 'img-md img-circle img-user media-object', alt: ""
      elsif size == 'sm'
        image_tag model.image.sm, class: 'img-sm img-circle img-user media-object', alt: ""
      elsif size == 'xs'
        image_tag model.image.md, class: 'img-xs img-circle img-user media-object', alt: ""
      elsif size == 'cover'
        image_tag model.image.cover, class: 'img-circle img-user media-object', alt: ""
      elsif size == 'big_tumb'
        image_tag model.image.big_tumb, class: 'img-circle img-user media-object', alt: ""
      end
    else
      if size == 'lg'
        content_tag(:span, nil, class: 'img-lg img-user imc-circle bg-white icon-wrapper-lg icon-circle fa fa-bolt fa-5x')
      elsif size == 'md'
        content_tag(:span, nil, class: 'img-md img-user imc-circle bg-white icon-wrapper-md icon-circle fa fa-bolt fa-3x')
      elsif size == 'sm'
        content_tag(:span, nil, class: 'img-sm img-user imc-circle bg-white icon-wrapper-sm icon-circle fa fa-bolt fa-2x')
      elsif size == 'xs'
        content_tag(:span, nil, class: 'img-xs img-user imc-circle bg-white icon-wrapper-xs icon-circle fa fa-bolt')
      else
        content_tag(:i, nil, class: 'img-xxs img-user imc-circle bg-white icon-wrapper-xxs icon-circle fa fa-bolt')
      end
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

  def fake_label
    if model.mode == 'in'
      'slp'
    elsif model.mode == 'out'
      'sep'
    end
  end


  def long_name
    if model.address
       "#{model.name} (#{model.address.street_name})"
    else
      model.name
    end
  end

  def name_with_users
    if model.users.any?
      model.name + " (" + model.users.uniq.collect{|user| if !(user.created_by_invite? && !user.invitation_accepted?) then user.profile.first_name else next end}.compact.join(", ") + ")"
    else
      model.name
    end
  end


  def link_to_delete
    link_to(
      t('delete'),
      model,
      remote: false,
      class: 'btn btn-danger btn-labeled fa fa-trash',
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
      t('edit_metering_point'),
      edit_metering_point_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-labeled fa fa-cog',
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
      content_tag(:i, t("add_or_remove_users"), class: 'btn btn-default btn-rounded btn-labeled fa fa-link'),
      edit_users_metering_point_path(model),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal'
      })
  end

  def edit_readings
    link_to(
      content_tag(:i, t("edit_readings"), class: 'btn btn-default btn-rounded btn-labeled fa fa-link'),
      edit_readings_metering_point_path(model),
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
      wizard_wizard_meters_path(metering_point_id: model.id),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-backdrop' => 'static'
      })
  end


  def new_contract
    link_to(
      content_tag(:i, t("establish_data_connection"), class: 'btn btn-default btn-rounded btn-labeled fa fa-plus'),
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
      content_tag(:i, t("add_to_dashboard"), class: 'btn btn-purple btn-labeled fa fa-link'),
      add_metering_point_dashboard_path(metering_point_id: model.id, dashboard_id: current_user.dashboard.id),
      {
        :remote         => true,
      })
  end

  def remove_from_dashboard
    link_to(
      content_tag(:i, t("remove_from_dashboard"), class: 'btn btn-default btn-rounded btn-labeled fa fa-remove'),
      remove_metering_point_dashboard_path(metering_point_id: model.id, dashboard_id: current_user.dashboard.id),
      {
        :remote         => true,
      })
  end

  def display_in_series
    link_to(
      content_tag(:i, t('start_display'), class: 'btn btn-success btn-labeled fa fa-bar-chart'),
      display_metering_point_in_series_dashboard_path(metering_point_id: model.id, dashboard_id: current_user.dashboard.id),
      {
        :remote         => true,
      })
  end

  def remove_from_series
    link_to(
      content_tag(:i, t('stop_display'), class: 'btn btn-danger btn-labeled fa fa-bar-chart'),
      remove_metering_point_from_series_dashboard_path(metering_point_id: model.id, dashboard_id: current_user.dashboard.id),
      {
        :remote         => true,
      })
  end

  def submit_reading
    link_to(
      content_tag(:i, t("submit_reading"), class: 'btn btn-default btn-rounded btn-labeled fa fa-plus'),
      new_reading_path(metering_point_id: model.id),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal'
      })
  end

  def get_reading
    link_to(
      content_tag(:i, t("get_reading"), class: 'btn btn-default btn-rounded btn-labeled fa fa-database'),
      get_reading_metering_point_path(metering_point_id: model.id),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal'
      })
  end

  def new_invitations
    link_to(
      t("invite_friends_to_join_this_metering_point"),
      send_invitations_metering_point_path,
      {
        :remote         => true,
        :class          => 'btn start_modal btn-success btn-labeled fa fa-user-plus',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal'
      })
  end




end
