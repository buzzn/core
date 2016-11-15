# coding: utf-8
describe "BankAccount Model" do

  let(:user_with_metering_point) { Fabricate(:user_with_metering_point) }
  let(:manager_group) {Fabricate(:group)}
  let(:manager_of_group) do
    user = Fabricate(:user)
    user.add_role(:manager, manager_group)
    user
  end
  let(:member_group) {Fabricate(:group)}
  let(:member_of_group) do
    user = Fabricate(:user)
    user.add_role(:member, member_group)
    user
  end
  let(:contract) do
    contract = Fabricate(:power_giver_contract)
    contract.metering_point = user_with_metering_point.roles.first.resource
    contract.save!
    contract
  end
  let(:user) { Fabricate(:user) }
  let(:admin) { Fabricate(:admin) }
  let(:params) do
    { holder: 'Me And The Corner', iban: 'DE23100000001234567890',
      bic: '123456789', bank_name: 'Yellow Submarine',
      bank_accountable_type: Contract.to_s,
      bank_accountable_id: contract.id }
  end
  let(:bank_account) do
    account = Fabricate(:bank_account)
    account.bank_accountable = contract
    account.save!
    account
  end

  # TODO check the contracting party permissions bits with all CRUD
  [:manager_of_group, :admin, :user_with_metering_point].each do |u|
    it "creates BankAccount for given contract with #{u}" do
      user = send(u)
      contract.group = manager_group
      contract.save!

      bank_account = BankAccount.guarded_create(user, params, contract)
      expect(bank_account.id).not_to be_nil
    end

    it "retrieves BankAccount of contract with #{u}" do
      user = send(u)
      contract.group = manager_group
      contract.save!

      account = BankAccount.guarded_retrieve(user, bank_account.id)
      expect(account.id).to eq bank_account.id

      expect {BankAccount.guarded_retrieve(user, 'some-unknown-id') }.to raise_error Buzzn::RecordNotFound
    end

    it "updates BankAccount of contract with #{u}" do
      user = send(u)
      contract.group = manager_group
      contract.save!

      account = BankAccount.guarded_update(user, id: bank_account.id, holder: 'Me')
      expect(BankAccount.find(account.id).holder).to eq 'Me'

      expect {BankAccount.guarded_update(user, id: 'some-unknown-id') }.to raise_error Buzzn::RecordNotFound
    end

    it "deletes BankAccount of contract with #{u}" do
      user = send(u)
      contract.group = manager_group
      contract.save!

      BankAccount.guarded_delete(user, bank_account.id)
      expect(BankAccount.where(id: bank_account.id)).to eq []

      expect {BankAccount.guarded_delete(user, 'some-unknown-id') }.to raise_error Buzzn::RecordNotFound
    end
  end

  [:anonymous, :user, :member_of_group].each do |u|
    it "does not create BankAccount of contract with #{u}" do
      user = send(u) if u != :anonymous
      contract.group = member_group
      contract.save!

      expect { BankAccount.guarded_create(user, params,
                                          contract) }.to raise_error Buzzn::PermissionDenied
    end

    it "does not retrieve BankAccount of contract with #{u}" do
      user = send(u) if u != :anonymous
      contract.group = member_group
      contract.save!

      expect { BankAccount.guarded_retrieve(user, bank_account.id) }.to raise_error Buzzn::PermissionDenied
    end

    it "does not update BankAccount of contract with #{u}" do
      user = send(u) if u != :anonymous
      contract.group = member_group
      contract.save!

      expect { BankAccount.guarded_update(user, bank_account.id,
                                          holder: 'Me') }.to raise_error Buzzn::PermissionDenied
    end

    it "does not delete BankAccount of contract with #{u}" do
      user = send(u) if u != :anonymous
      contract.group = member_group
      contract.save!

      expect { BankAccount.guarded_delete(user, bank_account.id) }.to raise_error Buzzn::PermissionDenied
    end
  end

  it 'filters', :retry => 3 do
    3.times { Fabricate(:bank_account) }

    [bank_account.holder, bank_account.bank_name, bank_account.bic].each do |val|

      len = val.size/2

      [val, val.upcase, val.downcase, val[0..len], val[-len..-1]].each do |value|
        bank_accounts = BankAccount.filter(value)
        expect(bank_accounts).to include(bank_account)
        expect(bank_accounts.size).to be < 3
      end
    end
  end


  it 'can not find anything' do
    Fabricate(:bank_account)
    bank_accounts = BankAccount.filter('Der Clown ist müde und geht nach Hause.')
    expect(bank_accounts.size).to eq 0
  end


  it 'filters gives all with no params' do
    Fabricate(:bank_account)
    Fabricate(:bank_account)

    bank_accounts = BankAccount.filter(nil)
    expect(bank_accounts.size).to eq BankAccount.count
  end
end
