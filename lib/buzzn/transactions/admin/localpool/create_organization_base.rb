require_relative '../localpool'
require_relative '../../../schemas/transactions/organization/create'

module Transactions::Admin::Localpool::CreateOrganizationBase

  def schema
    Schemas::Transactions::Organization::CreateWithNested
  end

  def create_contact_address(params:, resource:)
    super(params: params[:contact] || {})
  end

  def create_contact(params:, resource:)
    super(params: params, method: :contact)
  end

  def create_legal_representation(params:, resource:)
    super(params: params, method: :legal_representation)
  end

  def new_organization(params:, resource:)
    Organization::GeneralResource.new(
      *super(resource.organizations, params)
    )
  end

end
