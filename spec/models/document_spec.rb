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
