require_relative '../website_form'

class Transactions::Website::WebsiteForm::UpdateInternal < Transactions::Base

  validate :schema
  check :authorization, with: :'operations.authorization.update'
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Website::WebsiteForm::UpdateInternal
  end

end
