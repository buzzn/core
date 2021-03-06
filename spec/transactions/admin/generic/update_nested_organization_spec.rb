require_relative '../../shared_nested_address'
require_relative '../../shared_nested_person'
require 'buzzn/transactions/admin/generic/update_nested_organization'

describe Transactions::Admin::Generic::UpdateNestedOrganization, order: :defined do

  let(:organization) { create(:organization, :with_contact) }

  let(:customer_organization) { create(:organization, :with_contact) }

  let(:localpool) { create(:group, :localpool, owner: organization) }

  let(:operator) { create(:account, :buzzn_operator) }

  let(:another_person) { create(:person) }

  let!(:contract) do
    create(:contract, :localpool_powertaker,
           customer: customer_organization,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:localpool_resource) { Admin::LocalpoolResource.all(operator).first }
  let(:localpool_owner_resource) { localpool_resource.owner }
  let(:localpool_power_taker_contract_customer_resource) do
    localpool_resource.localpool_power_taker_contracts.first.customer
  end

  [:localpool_power_taker_contract_customer_resource, :localpool_owner_resource].each do |r|
    context r.to_s do

      it_behaves_like 'update without address', Transactions::Admin::Generic::UpdateNestedOrganization.new, name: 'Zappa-For-President' do
        let(:resource) { send(r) }
      end

      it_behaves_like 'update with address', Transactions::Admin::Generic::UpdateNestedOrganization.new, name: 'The Big Blue Coop', additional_legal_representation: 'Jaques Mayol, Enzo Majorca' do
        let(:resource) { send(r) }
      end

      context 'contact' do
        it_behaves_like 'update without person', Transactions::Admin::Generic::UpdateNestedOrganization.new, :contact, name: 'Zappa-For-President-Forever' do
          let(:resource) { send(r) }
        end
        it_behaves_like 'update with person without address', Transactions::Admin::Generic::UpdateNestedOrganization.new, :contact, name: 'Elvis-Lives-Forever' do
          let(:resource) { send(r) }
        end
        it_behaves_like 'update with person with address', Transactions::Admin::Generic::UpdateNestedOrganization.new, :contact, name: 'Mamas-and-Papas' do
          let(:resource) { send(r) }
        end

        it 'assigns the contact with an existing contact' do
          resource = send(r)
          transaction = Transactions::Admin::Generic::UpdateNestedOrganization.new
          json = {
            'updated_at' => resource.updated_at.as_json,
            'contact' => { id: another_person.id }
          }
          result = transaction.call(resource: resource, params: json)
          expect(result).to be_success
        end

        it 'assigns the contact without an existing contact' do
          resource = send(r)
          resource.object.contact = nil
          resource.object.save
          transaction = Transactions::Admin::Generic::UpdateNestedOrganization.new
          json = {
            'updated_at' => resource.updated_at.as_json,
            'contact' => { id: another_person.id }
          }
          result = transaction.call(resource: resource, params: json)
          expect(result).to be_success
        end

      end

      context 'legal_representation' do
        it_behaves_like 'update without person', Transactions::Admin::Generic::UpdateNestedOrganization.new, :legal_representation, name: 'Zappa-For-President-Again-And-Again' do
          let(:resource) { send(r) }
        end

        it_behaves_like 'update with person without address', Transactions::Admin::Generic::UpdateNestedOrganization.new, :legal_representation, name: 'Elvis-Lives-Again-And-Again' do
          let(:resource) { send(r) }
        end
      end

    end

  end

end
