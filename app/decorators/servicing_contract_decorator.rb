class ServicingContractDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def link_to_edit
    link_to(
      t('edit'),
      edit_servicing_contract_path(model),
      {
        remote: true,
        class: 'start_modal btn btn-danger pull-right',
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


end
