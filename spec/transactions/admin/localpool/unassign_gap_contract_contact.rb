describe Transactions::Admin::Localpool::UnassignGapContractCustomer do

  let(:admin) { create(:account, :buzzn_operator) }
  let(:person)       { create(:person) }
  let(:organization) do
    org = create(:organization, :with_address, :with_legal_representation)
    org.contact = person
    org.save!
    org
  end
  let(:localpoolperson) { create(:group, :localpool, :with_address, gap_contract_customer: person) }
  let(:localpoolorga) { create(:group, :localpool, :with_address, gap_contract_customer: organization) }

  let(:localpool_resource_person) { Admin::LocalpoolResource.all(admin).retrieve(localpoolperson.id) }
  let(:localpool_resource_orga) { Admin::LocalpoolResource.all(admin).retrieve(localpoolorga.id) }

  let(:result) do
    Transactions::Admin::Localpool::UnassignGapContractCustomer.new.(resource: localpool_resource_person)
  end

  context 'with person as gap contract customer' do

    let(:result) do
      Transactions::Admin::Localpool::UnassignGapContractCustomer.new.(resource: localpool_resource_person)
    end

    it 'unassigns' do
      expect(localpoolperson.gap_contract_customer).to eq person
      res = result
      expect(res).to be_success
      value = res.value!
      expect(value.gap_contract_customer).to be nil
    end

  end

  context 'with organization as gap contract customer' do

    let(:result) do
      Transactions::Admin::Localpool::UnassignGapContractCustomer.new.(resource: localpool_resource_orga)
    end

    it 'unassigns' do
      expect(localpoolorga.gap_contract_customer).to eq organization
      res = result
      expect(res).to be_success
      value = res.value!
      expect(value.gap_contract_customer).to be nil
    end

  end

end

