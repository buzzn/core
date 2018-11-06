require_relative '../website_form'

class Transactions::Website::WebsiteForm::UpdateProcessed < Transactions::Base

  validate :schema
  check :authorization, with: :'operations.authorization.update'
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Website::WebsiteForm::UpdateProcessed
  end

end
