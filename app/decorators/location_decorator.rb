class LocationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all
  decorates_association :address
  decorates_association :metering_points



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

  def link_to_edit
    link_to(
      model.address.name,
      edit_location_path(model),
      {
        remote: true,
        class: 'start_modal location_title',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

  def new_down_metering_point
    link_to(
      t('down_metering'),
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
      t('up_metering'),
      new_up_metering_point_path(location_id: model.id),
      {
        :remote                     => true,
        :class                      => 'start_modal',
        'data-toggle'               => 'modal',
        'data-target'               => '#myModal'
      })
  end


  def new_up_down_metering_point
    link_to(
      t('up_down_metering'),
      new_up_down_metering_point_path(location_id: model.id),
      {
        :remote                     => true,
        :class                      => 'start_modal',
        'data-toggle'               => 'modal',
        'data-target'               => '#myModal'
      })
  end


  def new_diff_metering_point
    link_to(
      t('diff_metering'),
      new_diff_metering_point_path(location_id: model.id),
      {
        :remote                     => true,
        :class                      => 'start_modal',
        'data-toggle'               => 'modal',
        'data-target'               => '#myModal'
      })
  end



end
