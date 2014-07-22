class ProfileDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :friends
  decorates_association :received_friendship_requests
  decorates_association :user
  decorates_association :users
  decorates_association :metering_points
  decorates_association :groups
  decorates_association :residents


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
      content_tag(:i, '', class: 'fa fa-user')
    end
  end


  def image_tag_medium
    if model.image?
      image_tag model.image.medium, class: 'img-circle', size: '150x150'
    else
      content_tag(:i, '', class: 'fa fa-user')
    end
  end




end