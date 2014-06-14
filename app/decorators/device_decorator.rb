class DeviceDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all


  def thumb
    link_to image_tag_small, model
  end


  def image_tag_small
    if model.image?
      image_tag model.image.small, class: 'img-circle'
    else
      image_tag 'male.png'
    end
  end



  def edit

    if model.up?
      path = edit_up_device_path(model)
    else
      path = edit_down_device_path(model)
    end

    link_to(
      model.name,
      path,
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

end
