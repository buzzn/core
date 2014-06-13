class ProfileDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def thumb
    link_to image_tag_small, model
  end


  def image_tag_small
    size = '30x30'
    if model.image?
      image_tag model.image.small, size: size, class: 'img-circle'
    else
      image_tag 'male.png', size: size
    end
  end


  def image_tag_medium
    if model.image?
      image_tag model.image.medium, class: 'img-circle'
    else
      image_tag 'male.png'
    end
  end


end