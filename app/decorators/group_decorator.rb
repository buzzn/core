class GroupDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :metering_points
  decorates_association :profile
  decorates_association :user
  decorates_association :metering_point_operator_contract
  decorates_association :servicing_contract


  def smart_image
 false
  end


  def link_to_edit
    link_to(
      t('edit'),
      edit_group_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-rounded btn-labeled fa fa-cog',
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


  def new_contract
    link_to(
      content_tag(:i, '', class: 'fa fa-plus-circle') + '  ' + t("add_contract"),
      new_contract_path(group_id: model.id),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => 'modal',
        'data-target' => '#myModal'
      })
  end

end