class ProfileDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def thumb
    link_to image_tag_small, model
  end


  def image_tag_small
    if model.image?
      image_tag model.image.small, class: 'img-circle', size: '30x30'
    else
      image_tag 'male.png', size: '30x30'
    end
  end


  def image_tag_medium
    if model.image?
      image_tag model.image.medium, class: 'img-circle', size: '150x150'
    else
      image_tag 'male.png', size: '150x150'
    end
  end


end