# coding: utf-8
describe BankAccount do

  entity(:user_with_register) do
    user = Fabricate(:user)
    user.add_role(Role::GROUP_ADMIN, register)
    user
  end

  entity(:register) { Fabricate(:meter).registers.first }

  entity(:manager_group) { Fabricate(:localpool) }

  entity(:manager_of_group) do
    user = Fabricate(:user)
    user.add_role(Role::GROUP_ADMIN, manager_group)
    user
  end

  entity(:member_group) { Fabricate(:localpool) }
  entity(:member_of_group) do
    user = Fabricate(:user)
    user.add_role(Role::GROUP_MEMBER, member_group)
    user
  end

  entity(:member_group_contract) do
    Fabricate(:metering_point_operator_contract, localpool: member_group)
  end

  entity(:register_contract) do
    Fabricate(:metering_point_operator_contract, register: register)
  end

  entity(:manager_group_contract) do
    Fabricate(:metering_point_operator_contract, localpool: manager_group)
  end

  entity(:user) { Fabricate(:user) }
  entity(:admin) { Fabricate(:admin) }

  let(:params) do
    { holder: 'Me And The Corner', iban: 'DE23100000001234567890',
      bic: '123456789', bank_name: 'Yellow Submarine',
      contracting_party_id: member_group_contract.id,
      contracting_party_type: member_group_contract.class }
  end

  entity!(:member_group_bank_account) do
    account = Fabricate(:bank_account)
    member_group_contract.contractor_bank_account = account
    member_group_contract.save!
    account
  end

  entity!(:manager_group_bank_account) do
    account = Fabricate(:bank_account, contracting_party: manager_of_group)
    manager_group_contract.contractor_bank_account = account
    manager_group_contract.save!
    account
  end

  entity!(:register_bank_account) do
    account = Fabricate(:bank_account, contracting_party: user_with_register)
    register_contract.contractor_bank_account = account
    register_contract.save!
    account
  end

  [:manager_of_group, :admin, :user_with_register].each do |u|
    it "creates BankAccount for given contract with #{u}" do
      user = send(u)

      contract = u == :manager_of_group ? manager_group_contract : register_contract
      bank_account = BankAccount.guarded_create(user, params, contract)
      expect(bank_account.id).not_to be_nil
    end

    it "retrieves BankAccount of contract with #{u}" do
      user = send(u)

      bank_account = u == :manager_of_group ? manager_group_bank_account : register_bank_account

      account = BankAccount.guarded_retrieve(user, bank_account.id)
      expect(account).to eq bank_account

      expect {BankAccount.guarded_retrieve(user, 'some-unknown-id') }.to raise_error Buzzn::RecordNotFound
    end

    it "updates BankAccount of contract with #{u}" do
      user = send(u)

      bank_account = u == :manager_of_group ? manager_group_bank_account : register_bank_account

      account = BankAccount.guarded_update(user, id: bank_account.id, holder: 'Me')
      expect(BankAccount.find(account.id).holder).to eq 'Me'

      expect {BankAccount.guarded_update(user, id: 'some-unknown-id') }.to raise_error Buzzn::RecordNotFound
    end

    it "deletes BankAccount of contract with #{u}" do
      begin
        user = send(u)

        bank_account = u == :manager_of_group ? manager_group_bank_account : register_bank_account

        BankAccount.guarded_delete(user, bank_account.id)
        expect(BankAccount.where(id: bank_account.id)).to eq []

        expect {BankAccount.guarded_delete(user, 'some-unknown-id') }.to raise_error Buzzn::RecordNotFound
      ensure
        # restart cached entity
        self.class.entities.delete(u == :manager_of_group ? :manager_group_bank_account : :register_bank_account)
      end
      
    end
  end

  [:anonymous, :user, :member_of_group].each do |u|
    it "does not create BankAccount of contract with #{u}" do
      user = send(u) if u != :anonymous

      expect { BankAccount.guarded_create(user, params,
                                          member_group_contract) }.to raise_error Buzzn::PermissionDenied
    end

    it "does not retrieve BankAccount of contract with #{u}" do
      user = send(u) if u != :anonymous

      expect { BankAccount.guarded_retrieve(user, member_group_bank_account.id) }.to raise_error Buzzn::PermissionDenied
    end

    it "does not update BankAccount of contract with #{u}" do
      user = send(u) if u != :anonymous

      expect { BankAccount.guarded_update(user, member_group_bank_account.id,
                                          holder: 'Me') }.to raise_error Buzzn::PermissionDenied
    end

    it "does not delete BankAccount of contract with #{u}" do
      user = send(u) if u != :anonymous

      expect { BankAccount.guarded_delete(user, member_group_bank_account.id) }.to raise_error Buzzn::PermissionDenied
    end
  end

  it 'filters' do
    bank_account = Fabricate(:bank_account)

    [bank_account.holder, bank_account.bank_name, bank_account.bic].each do |val|

      len = val.size/2

      [val, val.upcase, val.downcase, val[0..len], val[-len..-1]].each do |value|
        bank_accounts = BankAccount.filter(value)
        expect(bank_accounts).to include(bank_account)
      end
    end
  end


  it 'can not find anything' do
    bank_accounts = BankAccount.filter('Der Clown ist müde und geht nach Hause.')
    expect(bank_accounts.size).to eq 0
  end


  it 'filters gives all with no params' do
    bank_accounts = BankAccount.filter(nil)
    expect(bank_accounts.size).to eq BankAccount.count
  end
end
