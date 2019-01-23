describe Accounting::BalanceSheet do

  let(:localpool) { create(:group, :localpool) }
  let(:contract) do
    create(:contract, :localpool_processing,
           customer: localpool.owner,
           contractor: Organization::Market.buzzn,
           localpool: localpool)
  end

  let(:service) { Services::Accounting.new }
  let(:operator) { create(:account, :buzzn_operator) }

  it 'works' do
    service.book(operator, contract, 420, comment: 'initial debit')
    sheet = Accounting::BalanceSheet.new(contract)
    expect(sheet.total).to eql 420
    expect(sheet.entries.count).to eql 1
    expect(sheet.contract.id).to eql contract.id
  end
end
