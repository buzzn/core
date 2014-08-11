class DeviceDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :location
  decorates_association :metering_point
  decorates_association :asset
  decorates_association :assets


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
      content_tag(:i, '', class: 'fa fa-flash')
    end
  end


  def image_tag_small
    if model.image?
      image_tag model.image.small, class: 'img-circle', size: '45x45'
    else
      content_tag(:i, '', class: 'fa fa-flash')
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
    if model.out?
      path = edit_out_device_path(model)
    else
      path = edit_in_device_path(model)
    end

    link_to(
      raw(content_tag(:i, '', class: 'fa fa-cog') + t('edit')),
      path,
      {
        :remote       => true,
        :class        => 'start_modal btn btn-icon btn-danger btn-xs',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

  def new_asset
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle'),
      new_asset_path(model_id: model.id, model_type: 'device'),
      {
        :remote                     => true,
        :class                      => 'sidebar-plus',
        'data-toggle'               => 'modal',
        'data-target'               => '#myModal'
      })
  end

end
