module ApplicationHelper



  def mainnav_profiles_path
    active_link_to(
      content_tag(:i, nil, class: 'fa fa-user')+
      content_tag(:span,
        content_tag(:strong, t('users')), class: "menu-title"
      ),
      profiles_path, class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end
  def mainnav_profile_path(profile)
    active_link_to(
      content_tag(:i, nil, class: 'fa fa-user')+
      content_tag(:span,
        content_tag(:strong, profile.name), class: "menu-title"
      ),
      profile_path(profile), class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end



  def mainnav_groups_path
    active_link_to(
      content_tag(:i, nil, class: 'fa fa-users')+
      content_tag(:span,
        content_tag(:strong, t('groups')), class: "menu-title"
      ),
      groups_path, class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end

  def mainnav_organizations_path
    active_link_to(
      content_tag(:i, nil, class: 'fa fa-building-o')+
      content_tag(:span,
        content_tag(:strong, t('organizations')), class: "menu-title"
      ),
      organizations_path, class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end


  def mainnav_location_path(location)
    active_link_to(
      content_tag(:i, nil, class: 'fa fa-building-o')+
      content_tag(:span,
        content_tag(:strong, location.name), class: "menu-title"
      ),
      location_path(location), class: 'button white',
      :wrap_tag => :li, :class_active => 'active-link'
    )
  end


  def mainnav_device_path(device)
    active_link_to(
      content_tag(:i, nil, class: 'fa fa-building-o')+
      content_tag(:span,
        content_tag(:strong, device.name), class: "menu-title"
      ),
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


  def new_location
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_location_path,
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_new_location"),
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


  def new_in_device
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_in_device_path(:id),
      {
        :remote           => true,
        :class            => 'btn start_modal',
        'data-toggle'     => 'modal',
        'data-target'     => '#myModal',
        'data-tooltip'    => "true",
        'title'           => t("add_new_in_device"),
      })
  end

  def new_out_device
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_out_device_path(:id),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
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
