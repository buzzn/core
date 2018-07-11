describe BillingDocument do

  entity(:document) { Document.create('test/contract/file.jpg', File.read('spec/data/test.pdf'))}
  entity(:contract) { create(:contract, :metering_point_operator, begin_date: nil) }
  entity(:billing) { create(:billing, contract: contract) }

  it 'does not allow double entries' do
    BillingDocument.create(document_id: document.id, billing_id: billing.id)
    expect do
      BillingDocument.create(document_id: document.id, billing_id: billing.id)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

end
