require_relative '../power_taker'
require_relative '../../../../constraints/contract/base'
require_relative '../../../person/create'
require_relative '../../../organization/create'

module Schemas::Transactions

  Admin::Contract::PowerTaker::CUSTOMER_TYPES = ['person', 'organization']

  Admin::Contract::PowerTaker::CreateBase = Schemas::Support.Form(Schemas::Constraints::Contract::Base) do
    required(:register_meta).schema do
      required(:name).filled(:str?, max_size?: 64)
    end
  end

  Admin::Contract::PowerTaker::CreateWithAssign = Schemas::Support.Form(Admin::Contract::PowerTaker::CreateBase) do
    required(:customer).schema do
      required(:id).value(:int?)
      required(:type).value(included_in?: Admin::Contract::PowerTaker::CUSTOMER_TYPES)
    end
  end

  Admin::Contract::PowerTaker::CreateWithPerson = Schemas::Support.Form(Admin::Contract::PowerTaker::CreateBase) do
    required(:customer) do
      schema(Person::CreateWithAddress)
    end
  end

  Admin::Contract::PowerTaker::CreateWithOrganization = Schemas::Support.Form(Admin::Contract::PowerTaker::CreateBase) do
    required(:customer) do
      schema(Organization::CreateWithNested)
    end
  end

end
