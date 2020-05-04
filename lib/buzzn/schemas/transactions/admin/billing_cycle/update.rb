require_relative '../billing_cycle'

Schemas::Transactions::Admin::BillingCycle::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:name).filled(:str?, max_size?: 64)
  optional(:last_date).filled(:date?)
  required(:localpool).schema do
    required(:contact).schema do
      required(:email)
      required(:last_name)
      required(:first_name)
      required(:prefix)
    end
  end
  required(:contract).filled
  required(:contract).schema do
    required(:contact).filled
    required(:contact).schema do
      required(:email)
      required(:first_name)
      required(:last_name)
    end
  end
end
