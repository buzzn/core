require_relative '../website_form'

Schemas::Transactions::Website::WebsiteForm::UpdateInternal = Schemas::Support.Form(Schemas::Transactions::Update) do
  required(:processed).filled(:bool?)
  optional(:comment).maybe(:str?)
end
