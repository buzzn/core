class GroupDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def link_to_edit
    link_to(
      t('edit_group'),
      edit_group_path(model),
      {
        remote: true,
        class: 'start_modal',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

end