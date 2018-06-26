require_relative '../website_form'

class Transactions::WebsiteForm::Create < Transactions::Base

  validate :schema
  map :create_website_form, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::WebsiteForm::Create
  end

  def create_website_form(params:, resource:)
    WebsiteFormResource.new(
      *super(resource, params)
    )
  end

end
