class LocationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all
  decorates_association :address
  decorates_association :metering_point
  decorates_association :user
  decorates_association :devices
  decorates_association :users
  decorates_association :assets



  def image_tag_lg
    if model.metering_point && model.metering_point.image?
      image_tag model.metering_point.image.lg, class: 'img-circle img-lg img-border', alt: ""
    end
  end




  def thumb_small
    link_to image_tag_small, model
  end

  def image_tag_small
    if model.metering_point && model.metering_point.assets.any?
      image_tag model.metering_point.assets.first.image.small, class: 'img-circle', size: '45x45', alt: ""
    else
      icon_tag_small
    end
  end

  def icon_tag_small
    content_tag(:i, '', class: 'fa fa-home')
  end

  def link_to_delete
    if model.metering_point
      link_to(
        t('delete'),
        model,
        class: 'btn btn-danger disabled',
        :data => {
          :confirm => t('cannot_delete_location_while_metering_point_exists')
        })
    else
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
      content_tag(:i, '', class: 'fa fa-plus-circle'),
      metering_point_wizard_metering_points_path(location_id: model.id),
      {
        :class => 'content-plus',
        :remote       => true,
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end




end
