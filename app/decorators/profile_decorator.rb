class ProfileDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all



  def link_to_edit
    link_to(
      t('edit_profile'),
      edit_profile_path(model),
      {
        remote: true,
        class: 'start_modal',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end



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


  def image_tag_medium
    if model.image?
      image_tag model.image.medium, class: 'img-circle', size: '150x150'
    else
      image_tag 'male.png', size: '150x150'
    end
  end




end