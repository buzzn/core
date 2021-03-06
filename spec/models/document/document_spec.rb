describe Document do

  it 'creates and destroys' do
    doc = Document.new(filename: 'test/something')
    doc.data = 'somethingrandom'
    doc.store

    filepath = File.join('tmp/files/', doc.path)
    expect(Document.find_by_filename('something').read).to eq 'somethingrandom'
    expect(filepath).not_to eq 'somethingrandom'

    doc.destroy
    expect { doc.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(File.exist?(filepath)).to be false
  end

  entity(:files) { [build(:file, :png), build(:file, :txt), build(:file, :pdf)]}

  files.each do |data|
    it "creates valid metadata for #{data[:file]}" do
      doc = Document.new(filename: data[:file])
      doc.data = File.read('spec/data/' + data[:file])
      doc.store

      expect(doc.size).to eq data[:size]
      expect(doc.mime).to eq data[:mime]
      expect(doc.sha256).to eq data[:sha256]
    end
  end

  it 'retrieves' do
    document = Document.create(filename: 'test/me', data: 'now')
    doc = Document.find_by_filename('me')
    expect(doc).to eq document
    expect(doc.read).to eq 'now'
  end

  it 'updates' do
    document = Document.create(filename: 'test/me2', data: 'now')
    document.data = 'something else'
    document.store
    expect(document.read).to eq 'something else'
  end

  it 'produces same sha256 but different sha256_encrypted' do
    doc1 = Document.create(filename: 'one', data: 'samestring')
    doc2 = Document.create(filename: 'two', data: 'samestring')
    expect(doc1.sha256).to eq doc2.sha256
    expect(doc1.sha256_encrypted).not_to eq doc2.sha256_encrypted
  end

  context 'constraints', skip: 'does not rollback cleanly' do
    include_context :database_integrity

    let(:group) { create(:group, :localpool) }
    let(:contract) { create(:contract, :localpool_powertaker)}
    let(:billing) { create(:billing, contract: contract) }

    context 'group', database_integrity: true do
      let(:document) { Document.create(filename: 'test/contract/file.jpg', data: File.read('spec/data/test.pdf'))}
      it 'does not allow double entries' do
        group.documents << document
        expect do
          group.documents << document
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end

    end

    context 'billing', database_integrity: true do

      let(:document) { Document.create(filename: 'test/contract/file.jpg', data: File.read('spec/data/test.pdf'))}

      it 'does not allow double entries' do
        billing.documents << document
        expect do
          billing.documents << document
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end

    end

    context 'contract', database_integrity: true do

      let(:document) { Document.create(filename: 'test/contract/file.jpg', data: File.read('spec/data/test.pdf'))}

      it 'does not allow double entries' do
        contract.documents << document
        expect do
          contract.documents << document
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end

    end

  end

end
