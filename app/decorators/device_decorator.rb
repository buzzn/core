class DeviceDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :location
  decorates_association :metering_point
  decorates_association :asset
  decorates_association :assets


  def image_tag_device
    if model.image?
      image_tag model.image.sm, class: 'img-circle img-user media-object', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-flash')
    end
  end

  def image_tag_sm
    if model.image?
      image_tag model.image.sm, class: 'img-circle img-sm img-border', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-flash')
    end
  end

  def image_tag_lg
    if model.image?
      image_tag model.image.lg, class: 'img-circle img-lg img-border', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-flash')
    end
  end

  def link_to_delete
    link_to(
      t('delete'),
      model,
      remote: false,
      class: 'btn btn-danger',
      :method => :delete,
      :data => {
        :confirm => t('are_you_sure')
      })
  end



  def link_to_edit
    link_to(
      t('edit'),
      edit_device_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-rounded btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end


end
