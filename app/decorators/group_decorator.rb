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
        class: 'btn btn-danger',
        :data => {
          :confirm => t('cannot_delete_group_while_running_contracts_exists')
        })
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

  def image_tag_group
    if model.assets.any?
      image_tag model.assets.first.image.sm, class: 'img-circle img-user media-object', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-users')
    end
  end

  def image_tag_sm
    if model.assets.any?
      image_tag model.assets.first.image.sm, class: 'img-circle img-sm img-border', alt: ""
    else
      content_tag(:i, '', class: 'fa fa-users')
    end
  end

  def image_tag_lg
    if model.assets.any?
      image_tag model.assets.first.image.lg, class: 'img-circle img-lg img-border', alt: ""
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