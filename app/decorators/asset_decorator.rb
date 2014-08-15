class AssetDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all
  decorates_association :devices

  def thumb_small
    link_to image_tag_small, model
  end

  def image_tag_small
    if model.image?
      image_tag model.image.medium, class: 'img-thumbnail img-responsive', size: '140x140', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-bolt')
    end
  end

  def image_tag_large
    if model.image?
      image_tag model.image.large
    else
      content_tag(:i, '', class: 'fa fa-bolt')
    end
  end

  def link_to_show
    link_to(
      t('show'),
      asset_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-default btn-xs',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

  def link_to_edit
    link_to(
      t('edit'),
      edit_asset_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-danger btn-xs',
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
end