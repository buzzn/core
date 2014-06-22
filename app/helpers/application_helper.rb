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

end
