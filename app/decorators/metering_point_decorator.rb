class MeteringPointDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all
  decorates_association :devices
  decorates_association :meter
  decorates_association :users
  decorates_association :location
  decorates_association :group

  def thumb_small
    link_to image_tag_small, model, :data => { 'toggle' => 'tooltip', container: 'body', 'original-title' => model.name }, rel: 'tooltip'
  end

  def image_tag_small
    content_tag(:i, '', class: 'fa fa-map-marker')
  end

  def thumb_medium
    link_to image_tag_medium, model
  end

  def image_tag_medium
    if model.image?
      image_tag model.image.medium, class: 'img-circle', size: '150x150'
    else
      content_tag(:i, '', class: 'fa fa-map-marker')
    end
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


  def link_to_show
    link_to model.name, metering_point_path(model)
  end


  def link_to_edit
    link_to(
      raw(content_tag(:i, '', class: 'fa fa-cog') + t('edit')),
      edit_metering_point_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-icon btn-danger btn-xs',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end


  def new_register
    link_to(
      t("add_register"),
      new_register_path(metering_point_id: model.id),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end




  def new_device
    if model.out?
      path = new_out_device_path(metering_point_id: model.id)
    else
      path = new_in_device_path(metering_point_id: model.id)
    end
    link_to(
      '',
      path,
      {
        :remote       => true,
        :class        => 'sidebar-plus start_modal glyphicon glyphicon-plus-sign',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end



  def edit_users
    link_to(
      '',
      edit_users_metering_point_path(model),
      {
        :remote       => true,
        :class        => 'sidebar-plus start_modal glyphicon glyphicon-plus-sign',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end



end
