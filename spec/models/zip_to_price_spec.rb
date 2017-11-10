describe ZipToPrice do

  let(:dir) { 'db/csv' }
  let(:real_file) { File.join(dir, "GET_AG_2017ET_DTdot.csv") }
  let(:file1) { File.join(dir, "TEST1_GET_AG_2017ET_DTdot.csv") }
  let(:file2) { File.join(dir, "TEST2_GET_AG_2017ET_DTdot.csv") }

  before do
  end

  it 'imports all', :slow do
    ZipToPrice.from_csv(real_file)
    expect(ZipToPrice.count).to eq 14534
  end

  it 'imports idempotent' do
    ZipToPrice.from_csv(file1)
    csv1 = StringIO.new
    ZipToPrice.to_csv(csv1)

    ZipToPrice.from_csv(file1)
    csv2 = StringIO.new
    ZipToPrice.to_csv(csv2)

    expect(csv1.string).to eq csv2.string
    content = Buzzn::Utils::File.read(file1).gsub(/\r\n?/, "\n")
    expect(content.gsub(/[.]0;/, ';').split("\n")).to match_array csv1.string.gsub(/[.]0;/, ';').split("\n")
  end

  it 'imports replaces' do
    ZipToPrice.from_csv(file1)
    zips1 = ZipToPrice.all.select(:zip).collect {|zp| zp.zip }

    ZipToPrice.from_csv(file2)
    zips2 = ZipToPrice.all.select(:zip).collect {|zp| zp.zip }

    expect(zips1 - zips2).to eq zips1
    expect(zips2 - zips1).to eq zips2
  end
end
