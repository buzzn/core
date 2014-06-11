class ProfileDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def thumbnail_link
    link_to image_tag_small, profile
  end


  def image_tag_small
    size = '30x30'
    if model.image?
      image_tag profile.image.small, size: size, class: 'img-circle'
    else
      image_tag 'male.png', size: size
    end
  end


  def image_tag_medium
    if model.image?
      image_tag profile.image.medium, class: 'img-circle'
    else
      image_tag 'male.png'
    end
  end


end