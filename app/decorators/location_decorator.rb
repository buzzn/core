class LocationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all
  decorates_association :address
  decorates_association :metering_points

  def title
    if name
      name
    else
      address.name
    end
  end

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
      title,
      edit_location_path(model),
      {
        remote: true,
        class: 'start_modal',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

  def new_metering_point
    link_to(
      '',
      new_metering_point_path(location_id: model.id),
      {
        :remote                     => true,
        :class                      => 'start_modal glyphicon glyphicon-plus-sign',
        'data-toggle'               => 'modal',
        'data-target'               => '#myModal'
      })
  end




end
