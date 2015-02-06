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
      raw(content_tag(:i, '', class: 'fa fa-cog') + t('edit')),
      edit_user_registration_path,
      {
        class: 'btn btn-icon btn-danger btn-xs'
      }
    )
  end


  def image_tag_user
    if model.image?
      image_tag model.image.sm, class: 'img-circle img-user media-object', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-user')
    end
  end

  def image_tag_sm
    if model.image?
      image_tag model.image.sm, class: 'img-circle img-sm img-border', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-user')
    end
  end

  def image_tag_md
    if model.image?
      image_tag model.image.md, class: 'img-circle img-md img-border', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-user')
    end
  end

  def image_tag_lg
    if model.image?
      image_tag model.image.lg, class: 'img-circle img-lg img-border', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-user')
    end
  end



end