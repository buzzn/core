require 'buzzn/transactions/admin/bank_account/assign'

describe Transactions::Admin::BankAccount::Assign do

  let(:localpool) { create(:group, :localpool) }
  let(:localpoolr) { Admin::LocalpoolResource.all(operator).retrieve(localpool.id) }
  let(:operator) { create(:account, :buzzn_operator) }

  let(:person) do
    create(:person)
  end

  let(:first_bank_account) do
    create(:bank_account, owner: person)
  end

  let(:second_bank_account) do
    create(:bank_account, owner: person)
  end

  let(:another_person) do
    create(:person, :with_bank_account)
  end

  let(:contract) do
    create(:contract, :localpool_powertaker,
           customer: person,
           customer_bank_account: first_bank_account,
           contractor: Organization::Market.buzzn,
           localpool: localpool)

  end

  let(:contractr) { localpoolr.contracts.retrieve(contract.id) }

  context 'valid data' do

    let(:result) do
      Transactions::Admin::BankAccount::Assign.new.(resource: contractr,
                                                    person_or_org: :customer,
                                                    attribute: :customer_bank_account,
                                                    params: {
                                                      bank_account_id: second_bank_account.id,
                                                      updated_at: contract.updated_at.to_json
                                                    })
    end

    it 'assigns' do
      expect(contract.customer_bank_account).to eql first_bank_account
      expect(result).to be_success
      contract.reload
      expect(contract.customer_bank_account).to eql second_bank_account
    end
  end

  context 'invalid data' do

    context 'bank account does not belong to the person' do

      let(:result) do
        Transactions::Admin::BankAccount::Assign.new.(resource: contractr,
                                                      person_or_org: :customer,
                                                      attribute: :customer_bank_account,
                                                      params: {
                                                        bank_account_id: another_person.bank_accounts.first.id,
                                                        updated_at: contract.updated_at.to_json
                                                      })
      end

      it 'does not assign' do
        expect(contract.customer_bank_account).to eql first_bank_account
        expect {result}.to raise_error Buzzn::ValidationError, "{:bank_account=>\"does not exist or belong to person #{person.id}\"}"
        contract.reload
        expect(contract.customer_bank_account).to eql first_bank_account
      end

    end

    context 'bank account does not exist' do

      let(:result) do
        Transactions::Admin::BankAccount::Assign.new.(resource: contractr,
                                                      person_or_org: :customer,
                                                      attribute: :customer_bank_account,
                                                      params: {
                                                        bank_account_id: 2231232,
                                                        updated_at: contract.updated_at.to_json
                                                      })
      end

      it 'does not assign' do
        expect(contract.customer_bank_account).to eql first_bank_account
        expect {result}.to raise_error Buzzn::ValidationError, "{:bank_account=>\"does not exist or belong to person #{person.id}\"}"
        contract.reload
        expect(contract.customer_bank_account).to eql first_bank_account
      end

    end

  end

end
