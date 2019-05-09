describe Transactions::Admin::Localpool::AssignOrganizationMarket do

  let!(:localpool) { create(:group, :localpool) }

  let(:operator) { create(:account, :buzzn_operator) }

  let(:resource) { Admin::LocalpoolResource.all(operator).first }

  context 'invalid' do
    context 'not a market organization' do
      let(:general_org) { create(:organization) }

      ['distribution_system_operator', 'transmission_system_operator', 'electricity_supplier'].each do |attribute|
        let(:params) do
          {
            organization_id: general_org.id,
            updated_at: resource.object.updated_at.to_json
          }
        end
        let(:result) do
          Transactions::Admin::Localpool::AssignOrganizationMarket.new.(params: params, resource: resource, attribute: attribute)
        end

        it 'does fails' do
          expect {result}.to raise_error ActiveRecord::RecordNotFound
        end
      end

    end

    context 'the correct org' do
      orgs = [:distribution_system_operator, :transmission_system_operator, :electricity_supplier]
      orgs.each do |org|
        context org.to_s do
          let(org) { create(:organization, org)}

          let(:result) do
            Transactions::Admin::Localpool::AssignOrganizationMarket.new.(params: params, resource: resource, attribute: attribute)
          end

          let(:params) do
            {
              organization_id: send(org).id,
              updated_at: resource.object.updated_at.to_json
            }
          end

          let(:result) do
            Transactions::Admin::Localpool::AssignOrganizationMarket.new.(params: params, resource: resource, function: org)
          end

          it 'assigns' do
            old_org = resource.object.send(org)
            expect(result).to be_success
            resource.object.reload
            expect(resource.object.send(org)).not_to eql old_org
          end
        end

      end

    end

    context 'not the correct org' do
      orgs = [:distribution_system_operator, :transmission_system_operator, :electricity_supplier]
      orgs.each do |org|
        let(org) { create(:organization, org)}
      end

      orgs.each do |org|
        let(:result) do
          Transactions::Admin::Localpool::AssignOrganizationMarket.new.(params: params, resource: resource, attribute: attribute)
        end

        orgs.reject { |x| x == org }.each do |test_org|

          context "fails for #{test_org}" do

            let(:params) do
              {
                organization_id: send(test_org).id,
                updated_at: resource.object.updated_at.to_json
              }
            end

            let(:result) do
              Transactions::Admin::Localpool::AssignOrganizationMarket.new.(params: params, resource: resource, function: org)
            end

            it 'does fails' do
              expect {result}.to raise_error Buzzn::ValidationError
            end

          end

        end

      end

    end

  end

end
