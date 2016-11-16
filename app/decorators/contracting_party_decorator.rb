class ContractingPartyDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :bank_account
  decorates_association :address

  def link_to_edit
    link_to(
      t('edit_contracting_party'),
      edit_contracting_party_path(model),
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
      remote: false,
      class: 'btn btn-danger btn-labeled fa fa-trash',
      :method => :delete,
      :data => {
        :confirm => t('are_you_sure')
    })
  end



  def new_bank_account
    link_to(
      content_tag(:i, t('add_bank_account'), class: 'btn btn-default btn-rounded btn-labeled fa fa-plus'),
      new_bank_account_path(bank_accountable_id: model.id, bank_accountable_type: 'ContractingParty'),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
      })
  end

  def new_address
    link_to(
      content_tag(:i, t("create_address"), class: 'btn btn-default btn-rounded btn-labeled fa fa-plus'),
      new_address_path(addressable_id: model.id, addressable_type: 'Register'),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal'
      })
  end

end
