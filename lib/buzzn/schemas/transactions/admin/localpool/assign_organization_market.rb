module Schemas::Transactions

  Admin::Localpool::AssignOrganizationMarket = Schemas::Support.Form(Schemas::Transactions::Update) do
    required(:organization_id).value(:int?)
  end

end
