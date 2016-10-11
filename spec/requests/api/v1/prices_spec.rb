require 'buzzn/zip2price'
describe "Prices API" do

  
  let(:expected) do
    { "data" =>
      { "attributes" => {} }
    }
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

  it 'gets a price' do
    Buzzn::Zip2Price.types
      .zip([[1170, 2560, 3303],
            [1330, 2560, 3463],
            [910, 2560, 3043],
            [1170, 2560, 3303],
            [1170, 2560, 3303]]).each do |type, exp|
      params = { zip: '86916', kwh: '1000', tarif_type: type }
                                                   
      get_without_token "/api/v1/prices", params
      expect(response).to have_http_status(200)
      expected['data']['attributes']['baseprice_cents'] = exp[0]
      expected['data']['attributes']['energyprice_cents'] = exp[1]
      expected['data']['attributes']['total_cents'] = exp[2]
      expect(json).to eq expected
    end
  end

  it 'gives unknown zip' do
    params = { zip: '98765', kwh: '1000', tarif_type: 'other' }

    get_without_token "/api/v1/prices", params

    expect(response).to have_http_status(422)
    expect(json['errors'].size).to eq 1
    expect(json['errors'].first['source']['pointer']).to eq "/data/attributes/zip"
    
  end
end
