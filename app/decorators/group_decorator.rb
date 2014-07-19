class GroupDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :metering_points

  def link_to_edit
    link_to(
      raw(content_tag(:i, '', class: 'fa fa-cog') + t('edit')),
      edit_group_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-icon btn-danger btn-xs',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
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

  def thumb_small
    link_to image_tag_small, model
  end

  def thumb_medium
    link_to image_tag_medium, model
  end

  def image_tag_medium
    if model.image?
      image_tag model.image.medium, class: 'img-circle', size: '135x135'
    else
      content_tag(:i, '', class: 'fa fa-group')
    end
  end


  def image_tag_small
    if model.image?
      image_tag model.image.small, class: 'img-circle', size: '45x45'
    else
      content_tag(:i, '', class: 'fa fa-group')
    end
  end

end