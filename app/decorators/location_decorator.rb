class LocationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all
  decorates_association :address
  decorates_association :metering_points


  def add_metering_point
    h.link_to(
      t('add_metering_point'),
      new_metering_point_path,
      {
        remote: true,
        class: 'start_modal',
        'data-toggle' => "modal",
        'data-target' => '#myModal',
        "data-location_id" => model.id
      })
  end



end
