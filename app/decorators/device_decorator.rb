class DeviceDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all


  def thumb
    link_to image_tag_small, model
  end

  def thumb_medium
    link_to image_tag_medium, model
  end

  def image_tag_medium
    if model.image?
      image_tag model.image.medium, class: 'img-circle', size: '135x135'
    end
  end


  def image_tag_small
    if model.image?
      image_tag model.image.small, class: 'img-circle', size: '45x45'
    else
      image_tag 'male.png', size: '45x45'
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

end
