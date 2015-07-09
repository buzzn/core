class OrganizationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :assets

  def link_to_edit
    link_to(
      t('edit_organization'),
      edit_organization_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

  def link_to_delete
    link_to(
      t('delete'),
      model,
      remote: true,
      class: 'btn btn-danger btn-labeled fa fa-trash',
      :method => :delete,
      :data => {
        :confirm => t('are_you_sure')
      })
  end


end