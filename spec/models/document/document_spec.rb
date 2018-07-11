describe Document do

  entity!(:document) { Document.create('test/me', 'happy4ever') }

  it 'creates and destroys' do
    doc = Document.new(path: 'test/something')
    doc.store('now')

    expect(Document.find_by_path('test/something').read).to eq 'now'
    expect(File.read('tmp/files/test/something')).not_to eq 'now'

    doc.destroy
    expect { doc.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(File.exist?('tmp/files/test/something')).to be false
  end

  TEST_DATA = [
    {
      :file => 'test.png',
      :mime => 'image/png',
      :size => 17787,
      :sha256 => '49de6c289ace1f224ded6d813423a07a346debb0d5e662b4be8095b60af49a94'
    },
    {
      :file => 'test.txt',
      :mime => 'text/plain',
      :size => 9,
      :sha256 => 'efd2c46f61d312c1fb880ffc0589759eff34403864f93d376c7c3b7d816528b5'
    },
    {
      :file => 'test.pdf',
      :mime => 'application/pdf',
      :size => 9602,
      :sha256 => '0a1a44171994d640c3d4f75f919a05de519a13c26998e72ba2b242f0ef1e8b67'
    }
  ]

  TEST_DATA.each do |data|
    it "creates valid metadata for #{data[:file]}" do
      doc = Document.new(path: 'test/meta/' + data[:file])
      doc.store(File.read('spec/data/' + data[:file]))

      expect(doc.size).to eq data[:size]
      expect(doc.mime).to eq data[:mime]
      expect(doc.sha256).to eq data[:sha256]
    end
  end

  it 'retrieves' do
    doc = Document.find_by_path('test/me')
    expect(doc).to eq document
    expect(doc.read).to eq 'happy4ever'
    expect(File.read('tmp/files/test/me')).not_to eq 'happy4ever'
  end

  it 'updates' do
    begin
      document.store('something else')
      expect(document.read).to eq 'something else'
      expect(File.read('tmp/files/test/me')).not_to eq 'something else'

      doc = Document.find_by_path('test/me')
      expect(doc.read).to eq 'something else'
    ensure
      document.store('happy4ever')
    end
  end

  it 'path is unique' do
    expect {Document.create('test/me', 'try it') }.to raise_error ActiveRecord::RecordInvalid
  end
end
