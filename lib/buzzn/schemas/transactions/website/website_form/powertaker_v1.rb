require_relative '../website_form'

Schemas::Transactions::Website::WebsiteForm::PowertakerV1 = Schemas::Support.Form do

  required(:personalInfo).schema do

    optional(:person).schema do
      required(:email).value(:email?)
    end

    optional(:organization).schema do
      required(:contactPerson).schema do
        required(:email).value(:email?)
      end
    end

  end

end
