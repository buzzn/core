class LocationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all
  decorates_association :address
  decorates_association :metering_points


  def new_down_metering_point
    link_to(
      t("add_down_metering"),
      new_down_metering_point_path(location_id: model.id),
      {
        :remote                     => true,
        :class                      => 'start_modal',
        'data-toggle'               => 'modal',
        'data-target'               => '#myModal'
      })
  end

  def new_up_metering_point
    link_to(
      t("add_up_metering"),
      new_up_metering_point_path(location_id: model.id),
      {
        :remote                     => true,
        :class                      => 'start_modal',
        'data-toggle'               => 'modal',
        'data-target'               => '#myModal'
      })
  end



end
