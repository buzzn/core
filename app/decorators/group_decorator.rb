class GroupDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :metering_points
  decorates_association :profile
  decorates_association :user
  decorates_association :assets
  decorates_association :metering_point_operator_contract
  decorates_association :servicing_contract

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
    if model.metering_point_operator_contract && model.metering_point_operator_contract.running
      link_to(
        t('delete'),
        model,
        class: 'btn btn-danger disabled',
        :data => { 'toggle' => 'tooltip', container: 'body', 'original-title' => t('cannot_delete_group_while_running_contracts_exists') },
        rel: 'tooltip')
    else
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

  def thumb_small
    link_to image_tag_small, model
  end

  def thumb_medium
    link_to image_tag_medium, model
  end

  def image_tag_medium
    if model.assets.any?
      image_tag model.assets.first.image.medium, class: 'img-circle', size: '150x150', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-users')
    end
  end

  def image_tag_small
    if model.assets.any?
      image_tag model.assets.first.image.small, class: 'img-circle', size: '45x45', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-users')
    end
  end

  def new_asset
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle'),
      new_asset_path(assetable_id: model.id, assetable_type: 'Group'),
      {
        :remote                     => true,
        :class                      => 'content-plus',
        'data-toggle'               => 'modal',
        'data-target'               => '#myModal'
      })
  end

  def new_metering_point_operator_contract
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle') + '  ' + t("add_metering_point_operator_contract"),
      new_metering_point_operator_contract_path(group_id: model.id),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end

  def new_servicing_contract
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle') + '  ' + t("add_servicing_contract"),
      new_servicing_contract_path(group_id: model.id),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end

end