describe ZipToPrice do

  let(:dir) { 'db/csv' }
  let(:file1) { File.join(dir, 'GetAG_2018_ET_minimal.csv') }
  let(:file2) { File.join(dir, 'GetAG_2018_DT_minimal.csv') }

  before do
  end

  it 'imports' do
    ZipToPrice.from_csv(file1, true)
    expect(ZipToPrice.count).to eq 4
    ZipToPrice.from_csv(file2, false)
    expect(ZipToPrice.first.baseprice_euro_year_dt).not_to be_nil
    expect(ZipToPrice.by_zip('01337')).not_to be_nil
  end

end
