# coding: utf-8
describe "ContractingParty Model" do

  let(:organization) do
    Fabricate(:transmission_system_operator_with_address)
  end

  let(:other_organization) do
    Fabricate(:transmission_system_operator_with_address)
  end

  let(:address) do
    Fabricate(:address, street_name: 'Sachsenstr.', street_number: '8', zip: 86916, city: 'Kaufering', state: 'Bayern')
  end

  let(:current_user) { Fabricate(:user) }

  let(:other_user) { Fabricate(:user) }

  let(:admin) { Fabricate(:admin) }

  let(:other_register) { Fabricate(:register) }

  let(:bank_account) { Fabricate.build(:bank_account) }

  subject do
    Fabricate(:company_contracting_party, address: address, user: Fabricate(:user), organization: organization)
  end

  describe 'validation' do

    it 'checks readability' do
      expect(subject.readable_by?(current_user)).to be false
      expect(subject.readable_by?(subject.user)).to be true
      expect(subject.readable_by?(admin)).to be true
    end

    it 'checks legal entity on create' do
      subject = ContractingParty.create bank_account: bank_account,
                                        legal_entity: 'natural_person'
      expect(subject.valid?).to eq true
      expect(subject.reload.legal_entity).to eq 'natural_person'

      subject = ContractingParty.create bank_account: bank_account,
                                        legal_entity: 'something'
      expect(subject.valid?).to eq false
      expect(subject.errors[:legal_entity]).not_to be_nil
    end

    it 'checks legal entity on update' do
      subject.update organization: nil, legal_entity: 'natural_person'
      expect(subject.valid?).to eq true
      expect(subject.reload.legal_entity).to eq 'natural_person'

      subject.update organization: nil, legal_entity: 'something'
      expect(subject.valid?).to eq false
      expect(subject.errors[:legal_entity]).not_to be_nil
    end

    it 'checks company contracting_party can have natural person as legal entity' do
      subject.update legal_entity: 'natural_person'
      expect(subject.valid?).to eq false
      expect(subject.errors[:legal_entity]).not_to be_nil
    end

    it 'checks company legal entity needs an Organization' do
      subject.update organization: nil
      expect(subject.valid?).to eq false
      expect(subject.errors[:legal_entity]).not_to be_nil
    end

    it 'checks the existence of the associated organization on update' do
      subject.guarded_update(admin, organization_id: other_organization.id)
      expect(subject.reload.organization).to eq(other_organization)

      expect {
        subject.guarded_update(admin,
                               organization_id: "74aa64f4-5262-49c5-bba0-f15eeb063741")
      }.to raise_error Buzzn::RecordNotFound
      expect {
        subject.guarded_update(current_user,
                               organization_id: "74aa64f4-5262-49c5-bba0-f15eeb063741")
      }.to raise_error Buzzn::PermissionDenied
    end

    it 'checks the existence of the associated organization on create' do
      subject = ContractingParty.guarded_create(current_user,
                                                bank_account: bank_account,
                                                legal_entity: 'company',
                                                organization_id: other_organization.id)
      expect(subject.reload.organization).to eq(other_organization)

      expect {
        subject = ContractingParty.guarded_create(current_user,
                                                  bank_account: bank_account,
                                                  legal_entity: 'company',
                                                  organization_id: "74aa64f4-5262-49c5-bba0-f15eeb063741")
      }.to raise_error Buzzn::RecordNotFound
    end

    it 'checks the existence of the associated user on update' do
      expect {
        subject.guarded_update(current_user,
                               user_id: other_user.id)
      }.to raise_error Buzzn::PermissionDenied

      expect {
        subject.guarded_update(admin,
                               user_id: "74aa64f4-5262-49c5-bba0-f15eeb063741")
      }.to raise_error Buzzn::RecordNotFound

      subject.guarded_update(admin, user_id: other_user.id)
      expect(subject.reload.user).to eq(other_user)
    end

    it 'checks the existence of the associated user on create' do
      expect {
        ContractingParty.guarded_create(current_user,
                                        bank_account: bank_account,
                                        user_id: other_user.id)
      }.to raise_error Buzzn::PermissionDenied

      expect {
        subject = ContractingParty.guarded_create(current_user,
                                                  bank_account: bank_account,
                                                  user_id: "74aa64f4-5262-49c5-bba0-f15eeb063741")
      }.to raise_error Buzzn::RecordNotFound

      subject = ContractingParty.guarded_create(admin,
                                                bank_account: bank_account,
                                                user_id: other_user.id,
                                                legal_entity: 'natural_person')
      expect(subject.reload.user).to eq(other_user)
    end

    it 'checks the existence of the associated register on update' do
      expect {
        subject.guarded_update(current_user,
                               register_id: other_register.id)
      }.to raise_error Buzzn::PermissionDenied

      expect {
        subject.guarded_update(admin,
                               register_id: "74aa64f4-5262-49c5-bba0-f15eeb063741")
      }.to raise_error Buzzn::RecordNotFound

      subject.guarded_update(admin, register_id: other_register.id)
      expect(subject.reload.register).to eq(other_register)
    end

    it 'checks the existence of the associated register on create' do
      expect {
        ContractingParty.guarded_create(current_user,
                                        register_id: other_register.id)
      }.to raise_error Buzzn::PermissionDenied

      expect {
        subject = ContractingParty.guarded_create(current_user,
                                                  register_id: "74aa64f4-5262-49c5-bba0-f15eeb063741")
      }.to raise_error Buzzn::RecordNotFound

      subject = ContractingParty.guarded_create(admin,
                                                bank_account: bank_account,
                                                register_id: other_register.id,
                                                legal_entity: 'natural_person')
      expect(subject.reload.register).to eq(other_register)
    end
  end
end
