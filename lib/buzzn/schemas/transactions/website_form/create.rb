require_relative '../website_form'

Schemas::Transactions::WebsiteForm::Create = Schemas::Support.Form do
  configure do
    def valid_json?(json)
      !!JSON.parse(json)
    rescue
      false
    end
  end

  required(:form_name).value(included_in?: WebsiteForm.form_names.values)
  required(:form_content).filled(:str?, :valid_json?)
end
