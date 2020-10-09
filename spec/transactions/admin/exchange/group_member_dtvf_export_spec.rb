describe Transactions::Admin::Exchange::GroupMemberDtvfExport do
  let!(:admin) { create(:account, :buzzn_operator) }
  let!(:localpool) {
    create(:group, :localpool)
  }

  let!(:localpool_with_contracts) do
    create(:contract, :metering_point_operator, :with_tariff, :with_payment, localpool: localpool)
    localpool
  end

  let!(:c2) do
    create(:contract, :localpool_powertaker, :with_tariff, :with_payment, localpool: localpool, contract_number_addition: 92)
  end

  let!(:c1) do
    create(:contract, :localpool_powertaker, :with_tariff, :with_payment, localpool: localpool, contract_number_addition: 91)
  end

  let!(:localpool_resource) do
    Admin::LocalpoolResource.all(admin).retrieve(localpool_with_contracts.id)
  end


  let(:result) do
    Transactions::Admin::Exchange::GroupMemberDtvfExport.new.(resource: localpool_resource, params: {})
  end

  it 'converts the contractnumber to datev format' do
    expect(result).to be_success
    lines = result.value!.split("\n")
    expect(lines.size).to be(4)

    # There is some other test, which creates a localpool with various contracts
    expect(localpool.contracts.size).to be(4)
    expect(lines[0]).to start_with 'DTVF;700;16;Debitoren/Kreditoren;5;2,01907E+16;;RE;info;;557718;38017;20190101;5;;;;;;0;;;;;;74252;4;;;;'
    expect(lines[1]).to start_with 'Konto;Name (Adressattyp Unternehmen);Unternehmensgegenstand;Name (Adressattyp'

    #  Sometimes the contracts get mixed up, which makes it hard to check.
    contract_lines = [lines[2], lines[3]].sort
    expect(contract_lines[0]).to start_with "600#{c1.contract_number_addition};;;#{c1.contact.last_name};#{c1.contact.first_name};;1;;germany;;Frau;;;;;#{c1.contact.address.street}"
    expect(contract_lines[1]).to start_with "600#{c2.contract_number_addition};;;#{c2.contact.last_name};#{c2.contact.first_name};;1;;germany;;Frau;;;;;#{c2.contact.address.street}"
  end

end