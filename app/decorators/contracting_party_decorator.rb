class ContractingPartyDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :bank_account
  decorates_association :address

  def link_to_edit
    link_to(
      t('edit'),
      edit_contracting_party_path(model),
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



  def new_bank_account
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_bank_account_path(bank_accountable_id: model.id, bank_accountable_type: 'ContractingParty'),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_bank_account"),
      })
  end

  def new_address
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_address_path(addressable_id: model.id, addressable_type: 'ContractingParty'),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_address"),
      })
  end

end
