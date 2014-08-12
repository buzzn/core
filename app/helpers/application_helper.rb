module ApplicationHelper

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
      t("add_new_device"),
      new_in_device_path,
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end

end
