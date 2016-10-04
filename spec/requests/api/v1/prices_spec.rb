require 'buzzn/zip2price'
describe "Prices API" do

  
  let(:expected) do
    { "data" =>
      { "attributes" =>
        { "workprice" => 4.88,
          "baseprice" => 51.24
        } } }
  end

  before(:all) do
    csv_dir = 'db/csv'
    zip_vnb = File.read(File.join(csv_dir, "plz_vnb_test.csv"))
    zip_ka = File.read(File.join(csv_dir, "plz_ka_test.csv"))
    nne_vnb = File.read(File.join(csv_dir, "nne_vnb.csv"))
    ZipKa.from_csv(zip_ka)
    ZipVnb.from_csv(zip_vnb)
    NneVnb.from_csv(nne_vnb)
  end

  it "does not get a price" do
    get_without_token "/api/v1/prices"

    expect(response).to have_http_status(422)
    expect(json['errors'].size).to eq 3
  end

  it 'does get a price' do
    Buzzn::Zip2Price.types
      .zip([33.03, 34.63, 30.43, 33.03, 33.03]).each do |type, total|
      params = { zip: '86916', kwh: '1000', tarif_type: type }
                                                   
      get_without_token "/api/v1/prices", params

      expect(response).to have_http_status(200)
      expected['data']['attributes']['total'] = total
      expect(json).to eq expected
    end
  end

  it 'does gives unknown zip' do
    params = { zip: '98765', kwh: '1000', tarif_type: 'other' }

    get_without_token "/api/v1/prices", params

    expect(response).to have_http_status(422)
    expect(json['errors'].size).to eq 1
    expect(json['errors'].first['source']['pointer']).to eq "/data/attributes/zip"
    
  end
end
