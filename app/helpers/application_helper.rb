module ApplicationHelper



  def mainnav_profiles_path
    active_link_to(
      content_tag(:i, nil, class: 'fa fa-user')+
      content_tag(:span, t('users'), class: "menu-title" ),
      profiles_path, class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end

  def mainnav_groups_path
    active_link_to(
      content_tag(:i, nil, class: 'fa fa-users')+
      content_tag(:span, t('groups'), class: "menu-title"),
      groups_path, class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end

  def mainnav_organizations_path
    active_link_to(
      content_tag(:i, nil, class: 'fa fa-building-o')+
      content_tag(:span, t('organizations'), class: "menu-title"),
      organizations_path, class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end




  def mainnav_profile_path(profile)
    active_link_to(
      (
        profile.image? ?
        content_tag(:i, image_tag(profile.image.sm, class: 'img-circle', size: '20x20')) :
        content_tag(:i, nil, class: 'fa fa-home')
      ) + content_tag(:span, profile.name, class: "menu-title"),
      profile_path(profile), class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end




  def mainnav_metering_point_path(metering_point)
    active_link_to(
      (
        metering_point.image? ?
        content_tag(:i, image_tag(metering_point.image.sm, class: 'img-circle', size: '20x20')) :
        content_tag(:i, nil, class: 'fa fa-bolt')
      ) + content_tag(:span, metering_point.long_name, class: "menu-title"),
      metering_point_path(metering_point), class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end

  def mainnav_device_path(device)
    active_link_to(
      (
        device.image? ?
        content_tag(:i, image_tag(device.image.sm, class: 'img-circle', size: '20x20')) :
        content_tag(:i, nil, class: 'fa fa-plug')
      ) + content_tag(:span, device.name, class: "menu-title"),
      device_path(device), class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end





  # Return the watt size in a readable style.
  def human_readable_watt(watt)
    number_to_human( watt,  :precision   => 1,
                            :separator   => ',',
                            :significant => false,
                            :units => {
                              :unit     => "W",
                              :thousand => "kW",
                              :million  => "MW",
                              :billion  => "GW",
                              :trillion => "TW"
                            })
  end


  def link_to_external(link, html_options = {})
    html_options[:target] = "_blank"
    link_to(truncate(link, length: 24, separator: ' '), link, html_options)
  end


  def new_root_metering_point
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_metering_point_path,
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_metering_point"),
      })
  end

  def new_meter
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_meter_path,
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_meter"),
      })
  end

  def new_group
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_group_path,
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_new_group"),
      })
  end


  def new_device
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_device_path,
      {
        :remote           => true,
        :class            => 'btn start_modal',
        'data-toggle'     => 'modal',
        'data-target'     => '#myModal',
        'data-tooltip'    => "true",
        'title'           => t("add_new_device"),
      })
  end


  def new_organization
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_organization_path,
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end

end
