class BankAccountDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all


  def link_to_edit
    link_to(
      t('edit'),
      edit_bank_account_path(model),
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
      remote: false,
      class: 'btn btn-danger',
      :method => :delete,
      :data => {
        :confirm => t('are_you_sure')
    })
  end


end
