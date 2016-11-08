# coding: utf-8
describe "Forms API" do

  let(:params_without_user) do
    {:legal_entity=>"natural_person",
     :address=> {"street_name"=>"Lützowplatz",
                 "street_number"=>"17",
                 "city"=>"Berlin",
                 "zip"=>10785,
                 "country"=>"Germany",
                 "state"=>"Berlin",
                 "addition"=>"HH"},
     :meter=> {"manufacturer_name"=>"ferraris",
               "manufacturer_product_name"=>"AS 1440",
               "manufacturer_product_serialnumber"=>"3353987"},
     :metering_point=> {"uid"=>"10688251510000000000002677117"},
     :contract=>{:yearly_kilo_watt_per_hour=>1000, :tariff=>"single_tarif_meter"},
     :bank_account=> {:holder=>"Leora Deckow",
                      :iban=>"DE23100000001234567890",
                      :direct_debit=>false}
    }
  end

  let(:invalid_other_address) do
    { :other_address => {"street_name"=>"Lützowplatz" * 200,
                         "street_number"=>"17" * 200,
                         "city"=>"Berlin" * 200,
                         "zip"=>10785,
                         "country"=>"Germany",
                         "state"=>"Berlin" } }
  end

  let(:profile) do
    { :profile=> {"user_name"=>"Paula Braun",
                  "first_name"=>"Teagan",
                  "last_name"=>"Smitham",
                  "about_me"=>"Aliquam molestiae amet."} }
  end
  let(:params) do
    params_without_user.merge(:user=>{:email=>"alexandria_west@boyle.ca",
                                      :password=>"12345678"})
      .merge(profile)
  end

  before { Fabricate(:buzzn_energy) unless Organization.buzzn_energy }
 
  before(:all) do
    Bank.update_from(File.read("db/banks/BLZ_20160606.txt"))

    csv_dir = 'db/csv'
    zip_vnb = File.read(File.join(csv_dir, "plz_vnb_test.csv"))
    zip_ka = File.read(File.join(csv_dir, "plz_ka_test.csv"))
    nne_vnb = File.read(File.join(csv_dir, "nne_vnb.csv"))
    ZipKa.from_csv(zip_ka)
    ZipVnb.from_csv(zip_vnb)
    NneVnb.from_csv(nne_vnb)
  end

  it 'fails without params' do
    post_without_token '/api/v1/forms/power-taker', {}.to_json
    expect(response).to have_http_status(422)
  end

  it 'succeeds with valid params' do
    post_without_token '/api/v1/forms/power-taker', params.to_json
    expect(response).to have_http_status(201)
  end

  it 'succeeds with valid params and existing user' do
    access_token      = Fabricate(:simple_access_token)

    post_with_token '/api/v1/forms/power-taker', params_without_user.to_json, access_token.token
    expect(response).to have_http_status(201)
  end

  it 'fails with existing user and extra profile' do
    access_token      = Fabricate(:simple_access_token)

    post_with_token '/api/v1/forms/power-taker', params_without_user.merge(profile).to_json, access_token.token
    expect(response).to have_http_status(422)
    expect(json['errors'].size).to eq 1
    expect(json['errors'].first['source']['pointer']).to eq "/data/attributes/profile"
  end

  it 'fails with invalid nested attribtue' do
    post_without_token '/api/v1/forms/power-taker', params.merge(invalid_other_address).to_json

    expect(response).to have_http_status(422)
    expect(json['errors'].size).to eq 3
    json['errors'].each do |item|
      expect(item['source']['pointer']).to match /\/data\/attributes\/other_address\[.*\]/
    end
  end
end
