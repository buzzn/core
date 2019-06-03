require 'buzzn/transactions/admin/organization/create_organization_market'
require_relative '../../../support/params_helper.rb'

describe Transactions::Admin::Organization::CreateOrganizationMarket do

  let(:operator) { create(:account, :buzzn_operator) }
  let(:admin_resource) { AdminResource.new(operator) }
  let(:resource) { admin_resource.organization_markets }

  let(:result) do
    Transactions::Admin::Organization::CreateOrganizationMarket.new.(resource: resource, params: params)
  end

  let(:name) do
    'E-Corp'
  end

  let(:function_empty) do
    {
      market_partner_id: '666000001',
      edifact_email: 'ecorp@example.com',
      function: 'transmission_system_operator'
    }
  end

  let(:address) { {street: 'wallstreet', zip: '666', city: 'atlantis', country: 'GB'} }
  let(:contact) { build(:person) }

  let(:function_with_address) do
    {
      market_partner_id: '666000002',
      edifact_email: 'ecorp@example.com',
      function: 'electricity_supplier',
      address: address
    }
  end

  let(:function_with_contact_and_address) do
    {
      market_partner_id: '666000003',
      edifact_email: 'ecorp@example.com',
      function: 'distribution_system_operator',
      address: address,
      contact_person: build_person_json(contact, nil)
    }
  end

  let(:function_with_contact_with_address_and_address) do
    {
      market_partner_id: '666000004',
      edifact_email: 'ecorp@example.com',
      function: 'metering_point_operator',
      address: address,
      contact_person: build_person_json(contact, address)
    }
  end

  context 'invalid data' do
    context 'empty' do
      let(:params) do
        {}
      end

      it 'fails' do
        expect {result}.to raise_error Buzzn::ValidationError
      end
    end

    context 'empty 2' do
      let(:params) do
        { name: name }
      end

      it 'fails' do
        expect {result}.to raise_error Buzzn::ValidationError
      end
    end
  end

  context 'valid data' do
    after(:each) do
      res = result.value!
      res.destroy
    end

    context 'empty' do
      let(:params) do
        {
          name: name,
          functions: [ function_empty ]
        }
      end

      it 'works' do
        expect(result).to be_success
        res = result.value!
        expect(res).to be_a Organization::MarketResource
        obj = res.object
        expect(obj.market_functions.size).to eql 1
        market_function = obj.market_functions.first
        expect(market_function.market_partner_id).to eql '666000001'
      end
    end

    context 'function_with_address' do
      let(:params) do
        {
          name: name,
          functions: [ function_with_address ]
        }
      end

      it 'works' do
        expect(result).to be_success
        res = result.value!
        expect(res).to be_a Organization::MarketResource
        obj = res.object
        expect(obj.market_functions.size).to eql 1
        market_function = obj.market_functions.first
        expect(market_function.market_partner_id).to eql '666000002'
        expect(market_function.contact_person).to be_nil
        expect(market_function.address.street).to eql address[:street]
      end
    end

    context 'function_with_contact_and_address' do
      let(:params) do
        {
          name: name,
          functions: [ function_with_contact_and_address ]
        }
      end

      it 'works' do
        expect(result).to be_success
        res = result.value!
        expect(res).to be_a Organization::MarketResource
        obj = res.object
        expect(obj.market_functions.size).to eql 1
        market_function = obj.market_functions.first
        expect(market_function.market_partner_id).to eql '666000003'
        expect(market_function.contact_person).not_to be_nil
        expect(market_function.address.street).to eql address[:street]
      end
    end

    context 'function_with_contact_and_address' do
      let(:params) do
        {
          name: name,
          functions: [ function_with_contact_with_address_and_address ]
        }
      end

      it 'works' do
        expect(result).to be_success
        res = result.value!
        expect(res).to be_a Organization::MarketResource
        obj = res.object
        expect(obj.market_functions.size).to eql 1
        market_function = obj.market_functions.first
        expect(market_function.market_partner_id).to eql '666000004'
        expect(market_function.contact_person).not_to be_nil
        expect(market_function.contact_person.address.street).to eql address[:street]
        expect(market_function.address.street).to eql address[:street]
      end
    end

    context 'with all functions' do
      let(:params) do
        {
          name: name,
          functions: [ function_empty,
                       function_with_address,
                       function_with_contact_and_address,
                       function_with_contact_with_address_and_address ]
        }
      end

      it 'works' do
        expect(result).to be_success
        res = result.value!
        expect(res).to be_a Organization::MarketResource
        obj = res.object
        expect(obj.market_functions.size).to eql 4
        expect(obj.market_functions.map(&:market_partner_id)).to eql ['666000001', '666000002', '666000003', '666000004']
      end
    end
  end

end
