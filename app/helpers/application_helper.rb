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


  def new_location
    link_to(
      t("add_new_location"),
      new_location_path,
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end

  def new_group
    link_to(
      t("add_new_group"),
      new_group_path,
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end

  def new_in_device
    link_to(
      t("add_new_in_device"),
      new_in_device_path(:id),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end

  def new_out_device
    link_to(
      t("add_new_out_device"),
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
      t("add_new_organization"),
      new_organization_path,
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end

end
