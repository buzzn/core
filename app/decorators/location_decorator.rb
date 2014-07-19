class LocationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all
  decorates_association :address
  decorates_association :metering_points
  decorates_association :user
  decorates_association :devices
  decorates_association :users


  def title
    if name
      name
    else
      address.name
    end
  end

  def thumb_small
    link_to image_tag_small, model
  end

  def thumb_medium
    link_to image_tag_medium, model
  end

  def image_tag_medium
    if model.image?
      image_tag model.image.medium, class: 'img-circle', size: '150x150'
    else
      content_tag(:i, '', class: 'fa fa-home')
    end
  end

  def image_tag_small
    if model.image?
      image_tag model.image.small, class: 'img-home', size: '45x45'
    else
      content_tag(:i, '', class: 'fa fa-home')
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
      raw(content_tag(:i, '', class: 'fa fa-cog') + t('edit')),
      edit_location_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-icon btn-danger btn-xs',
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
        :class                      => 'content-plus start_modal glyphicon glyphicon-plus-sign',
        'data-toggle'               => 'modal',
        'data-target'               => '#myModal'
      })
  end




end
