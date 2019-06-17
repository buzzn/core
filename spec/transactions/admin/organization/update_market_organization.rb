require 'buzzn/transactions/admin/organization/create_organization_market'
require_relative '../../../support/params_helper.rb'

describe Transactions::Admin::Organization::UpdateOrganizationMarket do

  let(:operator) { create(:account, :buzzn_operator) }
  let(:admin_resource) { AdminResource.new(operator) }

  let(:result) do
    Transactions::Admin::Organization::UpdateOrganizationMarket.new.(resource: resource, params: params)
  end

  context 'without an address' do
    let!(:org) { create(:organization, :distribution_system_operator, address: nil) }
    let(:resource) do
      admin_resource.object.reload
      admin_resource.organization_markets.retrieve(org.id)
    end

    let(:address) { {street: 'wallstreet', zip: '666', city: 'atlantis', country: 'GB'} }
    let(:params) do
      {
        updated_at: org.updated_at.to_json,
        address: address
      }
    end

    it 'updates' do
      expect(result).to be_success
      org.reload
      expect(org.address).not_to be_nil
      expect(org.address.street).to eql 'wallstreet'
    end
  end

  context 'with an address' do
    let!(:org) { create(:organization, :distribution_system_operator) }
    let(:resource) do
      admin_resource.object.reload
      admin_resource.organization_markets.retrieve(org.id)
    end

    let(:address_missing) { {street: 'wallstreet', zip: '666', city: 'atlantis', country: 'GB'} }

    context 'missing' do
      let(:address) { address_missing }
      let(:params) do
        {
          updated_at: org.updated_at.to_json,
          address: address
        }
      end

      it 'does not updates' do
        expect {result}.to raise_error Buzzn::ValidationError, '{:address=>{:updated_at=>["is missing"]}}'
      end
    end

    context 'complete' do
      let(:address) { address_missing.merge(:updated_at => org.address.updated_at.to_json) }
      let(:params) do
        {
          updated_at: org.updated_at.to_json,
          address: address
        }
      end

      it 'updates' do
        expect(result).to be_success
        org.reload
        expect(org.address).not_to be_nil
        expect(org.address.street).to eql 'wallstreet'
      end
    end
  end

end
