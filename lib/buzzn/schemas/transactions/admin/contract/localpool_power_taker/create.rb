require_relative '../localpool_power_taker'
require_relative '../../../../constraints/contract/common'
require_relative '../../../person/create'
require_relative '../../../organization/create'
require_relative '../../register/create_meta'

module Schemas::Transactions

  Admin::Contract::Localpool::PowerTaker::CUSTOMER_TYPES = ['person', 'organization']

  Admin::Contract::Localpool::PowerTaker::CreateBase = Schemas::Support.Form(Schemas::Constraints::Contract::Common) do
    required(:begin_date).maybe(:date?)
    optional(:share_register_with_group).filled(:bool?)
    optional(:share_register_publicly).filled(:bool?)
    required(:register_meta) do
      schema(Admin::Register::CreateMetaLoose)
    end
  end

  Admin::Contract::Localpool::PowerTaker::CreateWithAssign = Schemas::Support.Form(Admin::Contract::Localpool::PowerTaker::CreateBase) do
    required(:customer).schema do
      required(:id).value(:int?)
      required(:type).value(included_in?: Admin::Contract::Localpool::PowerTaker::CUSTOMER_TYPES)
    end
  end

  Admin::Contract::Localpool::PowerTaker::CreateWithPerson = Schemas::Support.Form(Admin::Contract::Localpool::PowerTaker::CreateBase) do
    required(:customer) do
      schema(Person::CreateWithAddress)
    end
  end

  Admin::Contract::Localpool::PowerTaker::CreateWithOrganization = Schemas::Support.Form(Admin::Contract::Localpool::PowerTaker::CreateBase) do
    required(:customer) do
      schema(Organization::CreateWithNested)
    end
  end

end
