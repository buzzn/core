describe Document do

  it 'creates and destroys' do
    doc = Document.new(filename: 'test/something')
    doc.store('somethingrandom')

    expect(Document.find_by_filename('something').read).to eq 'somethingrandom'
    expect(File.read('tmp/files/sha256/0b/f6e2e388c96348fe46bd071d01e264dcb8e939456e8f4ab860351334875ad50b')).not_to eq 'somethingrandom'

    doc.destroy
    expect { doc.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(File.exist?('tmp/files/test/something')).to be false
  end

  entity(:files) { [build(:file, :png), build(:file, :txt), build(:file, :pdf)]}

  files.each do |data|
    it "creates valid metadata for #{data[:file]}" do
      doc = Document.new(filename: data[:file])
      doc.store(File.read('spec/data/' + data[:file]))

      expect(doc.size).to eq data[:size]
      expect(doc.mime).to eq data[:mime]
      expect(doc.sha256).to eq data[:sha256]
    end
  end

  it 'retrieves' do
    document = Document.create('test/me', 'now')
    doc = Document.find_by_filename('me')
    expect(doc).to eq document
    expect(doc.read).to eq 'now'
  end

  it 'updates' do
    document = Document.create('test/me2', 'now')
    document.store('something else')
    expect(document.read).to eq 'something else'
  end

  it 'does not delete with multiple references' do
    doc1 = Document.create('one', 'samestring')
    doc2 = Document.create('two', 'samestring')
    expect(doc1.sha256).to eq doc2.sha256
    expect(doc1.sha256).to eq '2573e9d755fa961f32ceb11d954aced58964f717ffc889e1d5f0762fd5547537'
    expect(File.exist?('tmp/files/sha256/37/2573e9d755fa961f32ceb11d954aced58964f717ffc889e1d5f0762fd5547537')).to be true
    doc1.destroy
    expect(File.exist?('tmp/files/sha256/37/2573e9d755fa961f32ceb11d954aced58964f717ffc889e1d5f0762fd5547537')).to be true
    doc2.destroy
    expect(File.exist?('tmp/files/sha256/37/2573e9d755fa961f32ceb11d954aced58964f717ffc889e1d5f0762fd5547537')).to be false
  end
end
