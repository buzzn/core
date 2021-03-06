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

    entity(:generator) { Pdf::Minimal.new(root: group) }

    context 'pdf' do

      it 'should not be deletable' do
        doc = Document.create(filename: 'test/relation/pdf/file.jpg', data: File.read('spec/data/test.pdf'))
        pdf = PdfDocument.create(document_id: doc.id, json: { :foo => :bar }, template_id: generator.template.id)
        doc.destroy
        expect do
          pdf.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

    end

  end

end
