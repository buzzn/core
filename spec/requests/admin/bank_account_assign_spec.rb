require_relative 'test_admin_localpool_roda'
require_relative '../../support/params_helper.rb'

shared_examples 'assigns bank account' do |person_or_org:, bank_account_holder:, base_object:|

  let(:path) {"#{base_path}/#{bank_account_holder.to_s.gsub('_', '-')}-bank-account"}

  let(:params) do
    {
      updated_at: send(base_object).updated_at,
      bank_account_id: send("second_bank_account_#{person_or_org}").id
    }
  end

  let(:invalid_params_other) do
    other = person_or_org == :person ? :organization : :person
    {
      updated_at: send(base_object).updated_at,
      bank_account_id: send("second_bank_account_#{other}").id
    }
  end

  context 'unauthenticated' do
    it '403' do
      PATCH path, nil, params
      expect(response).to have_http_status(403)
    end
  end

  context 'authenticated' do

    context 'invalid data' do

      it '422' do
        PATCH path, $admin, invalid_params_other
        expect(response).to have_http_status(422)
      end

    end

    context 'valid data' do

      it '200' do
        PATCH path, $admin, params
        expect(response).to have_http_status(200)
        send(base_object).reload
        expect(send(base_object).send("#{bank_account_holder}_bank_account")).to eql send("second_bank_account_#{person_or_org}")
      end

    end

  end
end

shared_context 'bank account entities' do

  let(:person)       { create(:person) }
  let(:organization) do
    org = create(:organization, :with_address, :with_legal_representation)
    org.contact = person
    org.save!
    org
  end

  let(:first_bank_account_person) do
    create(:bank_account, owner: person)
  end

  let(:second_bank_account_person) do
    create(:bank_account, owner: person)
  end

  let(:first_bank_account_organization) do
    create(:bank_account, owner: organization)
  end

  let(:second_bank_account_organization) do
    create(:bank_account, owner: organization)
  end

end

describe Admin::LocalpoolRoda, :request_helper do

  include_context 'bank account entities'
  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'gap contract customer' do

    [:organization, :person].each do |person_or_org|
      context "for when gap contract customer is #{person_or_org}" do
        it_behaves_like 'assigns bank account', person_or_org: person_or_org, bank_account_holder: :gap_contract_customer, base_object: :localpool do
          let(:localpool) { create(:group, :localpool, :with_address, gap_contract_customer: send(person_or_org)) }
          let(:base_path) { "/localpools/#{localpool.id}" }
        end
      end
    end

  end

end

describe Admin::ContractRoda, :request_helper do

  include_context 'bank account entities'
  def app
    TestAdminLocalpoolRoda # this defines the active application for this test
  end

  context 'customer' do

    [:organization, :person].each do |person_or_org|
      context "for when customer is #{person_or_org}" do

        it_behaves_like 'assigns bank account', person_or_org: person_or_org, bank_account_holder: :customer, base_object: :contract do
          let(:localpool) { create(:group, :localpool, :with_address) }
          let(:contract) do
            create(:contract, :localpool_powertaker,
                   customer: send(person_or_org),
                   localpool: localpool,
                   customer_bank_account: send("first_bank_account_#{person_or_org}")
                  )
          end
          let(:base_path) { "/localpools/#{localpool.id}/contracts/#{contract.id}" }
        end
      end

    end

  end

  context 'contractor' do

    [:organization, :person].each do |person_or_org|
      context "for when contractor is #{person_or_org}" do

        it_behaves_like 'assigns bank account', person_or_org: person_or_org, bank_account_holder: :contractor, base_object: :contract do
          let(:localpool) { create(:group, :localpool, :with_address, owner: send(person_or_org)) }
          let(:contract) do
            create(:contract, :localpool_powertaker,
                   localpool: localpool,
                   contractor_bank_account: send("first_bank_account_#{person_or_org}")
                  )
          end
          let(:base_path) { "/localpools/#{localpool.id}/contracts/#{contract.id}" }
        end
      end

    end

  end

end
