class DeviceDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all


  def thumb
    link_to image_tag_small, model
  end


  def image_tag_small
    if model.image?
      image_tag model.image.small, class: 'img-circle', size: '45x45'
    else
      image_tag 'male.png', size: '45x45'
    end
  end



  def edit

    if model.out?
      path = edit_out_device_path(model)
    else
      path = edit_in_device_path(model)
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
