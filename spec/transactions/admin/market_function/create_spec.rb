require 'buzzn/transactions/admin/market_function/create'
require_relative '../../../support/params_helper.rb'

describe Transactions::Admin::MarketFunction::Create do
  let(:operator) { create(:account, :buzzn_operator) }
  let(:admin_resource) { AdminResource.new(operator) }

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

  let(:result) do
    Transactions::Admin::MarketFunction::Create.new.(resource: resource, params: params, organization: org)
  end

  context 'duplicate functions' do
    let(:org) { create(:organization, :electricity_supplier, address: nil) }
    let(:resource) { admin_resource.organization_markets.retrieve(org.id).market_functions }
    let(:params) { function_with_address }

    it 'fails' do
      expect {result}.to raise_error Buzzn::ValidationError, '{:function=>["must be one of: distribution_system_operator, metering_point_operator, metering_service_provider, other, power_giver, power_taker, transmission_system_operator"]}'
    end

  end

  context 'valid data' do

    let(:org) { create(:organization, :market, address: nil) }
    let(:resource) { admin_resource.organization_markets.retrieve(org.id).market_functions }

    [:function_empty, :function_with_address, :function_with_contact_and_address, :function_with_contact_with_address_and_address].each do |function_params|

      context function_params.to_s do

        after(:each) do
          result.value!.object.destroy
        end

        let(:params) do
          Buzzn::Utils::Helpers.symbolize_keys_recursive(send(function_params))
        end

        it 'works' do
          expect(result).to be_success
          res = result.value!
          expect(res.object.market_partner_id).to eql params[:market_partner_id]
          unless params[:address].nil?
            expect(res.object.address).not_to be_nil
          end
          unless params[:contact_person].nil?
            expect(res.object.contact_person).not_to be_nil
            unless params[:contact_person][:address].nil?
              expect(res.object.contact_person.address).not_to be_nil
            end
          end
        end

      end

    end

  end

end
