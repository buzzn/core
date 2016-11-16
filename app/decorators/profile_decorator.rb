class ProfileDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :friends
  decorates_association :received_friendship_requests
  decorates_association :user
  decorates_association :users
  decorates_association :device
  decorates_association :registers
  decorates_association :groups
  decorates_association :residents


  def link_to_edit
    link_to(
      t('edit'),
      edit_profile_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

  def picture(size=nil)
    if model.image.present?
      if size == 'lg'
        image_tag model.image.lg, class: 'img-lg img-circle img-user media-object', alt: "profile-picture"
      elsif size == 'md'
        image_tag model.image.md, class: 'img-md img-circle img-user media-object', alt: "profile-picture"
      elsif size == 'sm'
        image_tag model.image.sm, class: 'img-sm img-circle img-user media-object', alt: "profile-picture"
      elsif size == 'xs'
        image_tag model.image.md, class: 'img-xs img-circle img-user media-object', alt: "profile-picture"
      elsif size == 'cover'
        image_tag model.image.cover, class: 'img-circle img-user media-object', alt: "profile-picture"
      elsif size == 'big_tumb'
        image_tag model.image.big_tumb, class: 'img-circle img-user media-object', alt: "profile-picture"
      end
    else
      if size == 'lg'
        content_tag(:span, nil, class: 'img-lg img-user imc-circle icon-wrapper-lg icon-circle bg-white fa fa-user fa-5x')
      elsif size == 'md'
        content_tag(:span, nil, class: 'img-md img-user imc-circle icon-wrapper-md icon-circle bg-white fa fa-user fa-3x')
      elsif size == 'sm'
        content_tag(:span, nil, class: 'img-sm img-user imc-circle icon-wrapper-sm icon-circle bg-white fa fa-user fa-2x')
      elsif size == 'xs'
        content_tag(:span, nil, class: 'img-xs img-user imc-circle icon-wrapper-xs icon-circle bg-white fa fa-user')
      else
        content_tag(:i, nil, class: 'img-xxs img-user imc-circle icon-wrapper-xxs icon-circle bg-white fa fa-user')
      end
    end
  end



end