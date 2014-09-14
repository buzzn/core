class ContractDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def link_to_edit
    link_to(
      t('edit'),
      edit_contract_path(model),
      {
        remote: true,
        class: 'start_modal btn btn-danger pull-right',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

end


