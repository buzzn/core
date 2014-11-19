class OrganizationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :assets

  def link_to_edit
    link_to(
      raw(content_tag(:i, '', class: 'fa fa-cog') + t('edit')),
      edit_organization_path(model),
      {
        remote: true,
        class: 'start_modal btn btn-icon btn-danger btn-xs',
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

  def new_asset
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle'),
      new_asset_path(assetable_id: model.id, assetable_type: 'Organization'),
      {
        :remote                     => true,
        :class                      => 'content-plus',
        'data-toggle'               => 'modal',
        'data-target'               => '#myModal'
      })
  end
end