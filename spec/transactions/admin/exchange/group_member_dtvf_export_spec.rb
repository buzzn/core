describe Transactions::Admin::Exchange::GroupMemberDtvfExport do
  let!(:admin) { create(:account, :buzzn_operator) }
  let!(:localpool) {
    create(:group, :localpool)
  }

  let!(:localpool_with_contracts) do
    create(:contract, :metering_point_operator, :with_tariff, :with_payment, localpool: localpool)
    create(:contract, :localpool_powertaker, :with_tariff, :with_payment, localpool: localpool)
    create(:contract, :localpool_powertaker, :with_tariff, :with_payment, localpool: localpool)
    localpool
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
    expect(lines[0]).to start_with 'DTVF;700;16;Debitoren/Kreditoren;5;2,01907E+16;;RE;info;;557718;38017;20190101;5;;;;;;0;;;;;;74252;4;;;;'
    expect(lines[1]).to start_with 'Konto;Name (Adressattyp Unternehmen);Unternehmensgegenstand;Name (Adressattyp natürl. Person);Vorname (Adressattyp natürl. Person);'
    expect(lines[2]).to start_with "60001;#{localpool.contracts[2].contact.last_name};;#{localpool.contracts[2].contact.last_name};#{localpool.contracts[2].contact.first_name};;;;germany;;Frau;;;;;#{localpool.contracts[2].contact.address.street}"
    expect(lines[3]).to start_with "60002;#{localpool.contracts[3].contact.last_name};;#{localpool.contracts[3].contact.last_name};#{localpool.contracts[3].contact.first_name};;;;germany;;Frau;;;;;#{localpool.contracts[3].contact.address.street}"
  end
end