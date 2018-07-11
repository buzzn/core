describe ContractDocument do

  entity(:document) { Document.create('test/contract/file.jpg', File.read('spec/data/test.pdf'))}
  entity(:contract) { create(:contract, :metering_point_operator, begin_date: nil) }

  it 'does not allow double entries' do
    ContractDocument.create(document_id: document.id, contract_id: contract.id)
    expect do
      ContractDocument.create(document_id: document.id, contract_id: contract.id)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

end
