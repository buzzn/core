require 'buzzn/zip2price'
describe "Prices API" do


  let(:expected) do
    { "data" =>
      { "attributes" => {} }
    }
  end

  let(:update_response) do
    {
      "data"=> {
        "id"=>"SOME_ID",
        "type"=>"prices",
        "attributes"=> {
          "type"=>"price",
          "name"=>"abcd",
          "begin-date"=>"2015-01-01",
          "energyprice-cents-per-kilowatt-hour"=>22.66,
          "baseprice-cents-per-month"=>400,
          "updatable"=>true,
          "deletable"=>true
        }
      }
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
      params = { zip: '86916', yearly_kilowatt_hour: '1000', metering_type: type }

      get_without_token "/api/v1/prices", params
      expect(response).to have_http_status(200)
      expected['data']['attributes']['baseprice_cents_per_month'] = exp[0]
      expected['data']['attributes']['energyprice_cents_per_kilowatt_hour'] = exp[1]
      expected['data']['attributes']['total_cents_per_month'] = exp[2]
      expect(json).to eq expected
    end
  end

  it 'gives unknown zip' do
    params = { zip: '98765', yearly_kilowatt_hour: '1000', metering_type: 'other' }

    get_without_token "/api/v1/prices", params

    expect(response).to have_http_status(422)
    expect(json['errors'].size).to eq 1
    expect(json['errors'].first['source']['pointer']).to eq "/data/attributes/zip"
  end

  it 'updates a price' do
    group = Fabricate(:localpool)
    price = Fabricate(:price, localpool: group)

    request_params = {
      id: price.id,
      name: 'abcd',
      begin_date: Date.new(2015, 1, 1),
      energyprice_cents_per_kilowatt_hour: 22.66,
      baseprice_cents_per_month: 400
    }

    full_access_token = Fabricate(:full_access_token)
    PATCH "/api/v1/prices/#{price.id}", full_access_token, request_params
    expect(response).to have_http_status(403)

    manager_access_token = Fabricate(:full_access_token)
    manager_user         = User.find(manager_access_token.resource_owner_id)
    manager_user.add_role(:manager, group)
    PATCH "/api/v1/prices/#{price.id}", manager_access_token, request_params
    expect(response).to have_http_status(200)
    update_response['data']['id'] = price.id
    expect(json).to eq update_response
  end
end
