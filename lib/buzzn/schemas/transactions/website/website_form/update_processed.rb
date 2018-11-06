require_relative '../website_form'

Schemas::Transactions::Website::WebsiteForm::UpdateProcessed = Schemas::Support.Form(Schemas::Transactions::Update) do
  required(:processed).filled(:bool?)
end
