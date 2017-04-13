# coding: utf-8
describe "Forms API" do

  let(:params_without_user) do
    {contracting_party: {
       legal_entity: "natural_person",
       provider_permission: true
     },
     :address=> {"street_name"=>"Lützowplatz",
                 "street_number"=>"17",
                 "city"=>"Berlin",
                 "zip"=>10785,
                 "country"=>"Germany",
                 "state"=>"Berlin",
                 "addition"=>"HH"},
     :meter=> {:metering_type=>"single_tarif_meter",
               "manufacturer_name"=>"ferraris",
               "manufacturer_product_name"=>"AS 1440",
               "manufacturer_product_serialnumber"=>"3353987"},
     :register=> {"uid"=>"10688251510000000000002677117"},
     :contract=>{
       terms: true,
       power_of_attorney: true,
       move_in: true,
       other_contract: true,
       yearly_kilowatt_hour: 1000,
       beginning: Time.now
     },
     :bank_account=> {:holder=>"Leora Deckow",
                      :iban=>"DE23100000001234567890",
                      :direct_debit=>false}
    }
  end

  let(:invalid_old_contract) do
    { old_contract: { customer_number: FFaker::Product.letters(10),
                      contract_number: FFaker::IdentificationESCO.drivers_license } }
  end

  let(:invalid_other_address) do
    { :other_address => {"street_name"=>"Lützowplatz" * 200,
                         "street_number"=>"17" * 200,
                         "city"=>"Berlin" * 200,
                         "zip"=>10785,
                         "country"=>"Germany",
                         "state"=>"Berlin" } }
  end

  let(:profile_without_phone) do
    { :profile=> {"user_name"=>"Paula Braun",
                  "first_name"=>"Teagan",
                  "last_name"=>"Smitham",
                  "about_me"=>"Aliquam molestiae amet."} }
  end
  let(:profile) do
    profile = profile_without_phone.dup
    profile[:profile]["phone"] = '087123321'
    profile
  end
  let(:params) do
    params_without_user.merge(:user=>{:email=>"alexandria_west@boyle.ca",
                                      :password=>"12345678"})
      .merge(profile)
  end

  before(:all) do
    Organization.buzzn_energy || Fabricate(:buzzn_energy)
    Organization.dummy_energy || Fabricate(:dummy_energy)

    if Bank.count == 0
      Bank.update_from(File.read("db/banks/BLZ_20160606.txt"))
    end

    if ZipKa.count == 0
      csv_dir = 'db/csv'
      zip_vnb = File.read(File.join(csv_dir, "plz_vnb_test.csv"))
      zip_ka = File.read(File.join(csv_dir, "plz_ka_test.csv"))
      nne_vnb = File.read(File.join(csv_dir, "nne_vnb.csv"))
      ZipKa.from_csv(zip_ka)
      ZipVnb.from_csv(zip_vnb)
      NneVnb.from_csv(nne_vnb)
    end
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

  it 'updates profile of existing user' do
    access_token      = Fabricate(:simple_access_token)
    User.find(access_token.resource_owner_id).profile.update!(phone: nil)

    post_with_token '/api/v1/forms/power-taker', params_without_user.merge(profile_without_phone).to_json, access_token.token

    expect(response).to have_http_status(422)
    expect(json['errors'].size).to eq 1
    expect(json['errors'].first['source']['pointer']).to eq "/data/attributes/profile[phone]"

    post_with_token '/api/v1/forms/power-taker', params_without_user.merge(profile).to_json, access_token.token
    expect(response).to have_http_status(201)
  end

  it 'fails with invalid nested attribtue' do
    post_without_token '/api/v1/forms/power-taker', params.merge(invalid_other_address).to_json

    expect(response).to have_http_status(422)
    expect(json['errors'].size).to eq 3
    json['errors'].each do |item|
      expect(item['source']['pointer']).to match /\/data\/attributes\/other_address\[.*\]/
    end
  end

  it 'fails with invalid nested old contract' do
    params.merge!(invalid_old_contract)
    post_without_token '/api/v1/forms/power-taker', params.to_json

    expect(response).to have_http_status(422)
    expect(json['errors'].size).to eq 1
    json['errors'].each do |item|
      expect(item['source']['pointer']).to match /\/data\/attributes\/old_contract\[.*\]/
    end
  end
end
