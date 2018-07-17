describe Document do
  # integration test for document classes

  context 'no relations' do

    it 'should be deletable' do
      doc = Document.create(filename: 'test/relation/file.jpg', data: File.read('spec/data/test.pdf'))
      doc.destroy
    end

  end

  entity(:contract) { create(:contract, :metering_point_operator, begin_date: nil) }
  entity(:billing) { create(:billing, contract: contract) }
  entity!(:group) { create(:group) }

  context 'with relations' do

    context 'contract' do

      it 'should not be deletable' do
        doc = Document.create(filename: 'test/relation/contract/file.jpg', data: File.read('spec/data/test.pdf'))
        ContractDocument.create(document_id: doc.id, contract_id: contract.id)
        expect do
          doc.destroy
        end.to raise_error(UncaughtThrowError)
      end

    end

    context 'billing' do

      it 'should not be deletable' do
        doc = Document.create(filename: 'test/relation/billing/file.jpg', data: File.read('spec/data/test.pdf'))
        BillingDocument.create(document_id: doc.id, billing_id: billing.id)
        expect do
          doc.destroy
        end.to raise_error(UncaughtThrowError)
      end

    end

    context 'group' do

      it 'should not be deletable' do
        doc = Document.create(filename: 'test/relation/group/file.jpg', data: File.read('spec/data/test.pdf'))
        GroupDocument.create(document_id: doc.id, group_id: group.id)
        expect do
          doc.destroy
        end.to raise_error(UncaughtThrowError)
      end

    end

    entity(:generator) { Pdf::Minimal.new(root: group) }

    context 'pdf' do

      it 'should not be deletable' do
        doc = Document.create(filename: 'test/relation/pdf/file.jpg', data: File.read('spec/data/test.pdf'))
        PdfDocument.create(document_id: doc.id, json: { :foo => :bar }, template_id: generator.template.id)
        expect do
          doc.destroy
        end.to raise_error(UncaughtThrowError)
      end

    end

  end

end
