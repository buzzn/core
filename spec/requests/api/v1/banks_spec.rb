# coding: utf-8
describe "Banks API" do

  let(:expected) do
    { "blz"=>"70022200", "bic"=>"FDDODEMMXXX", "description"=>"Fidor Bank", "zip"=>"80335",
     "place"=>"München", "name"=>"Fidor Bank München"}
  end
  
  before(:all) do
    file = File.read("db/banks/BLZ_20160905.txt")
    Bank.update_from(file)
  end

  it "does not get a bank" do
    get_without_token "/api/v1/banks", { bic: 'XXX' }
    expect(response).to have_http_status(404)

    get_without_token "/api/v1/banks", { iban: 'DE' }
    expect(response).to have_http_status(404)
  end

  it 'gets a bank' do
    get_without_token "/api/v1/banks", { bic: 'FDDODEMM' }
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq '55599'
    expect(json['data']['attributes']).to eq expected

    get_without_token "/api/v1/banks", { iban: 'DE2770022200123456789' }
    expect(response).to have_http_status(200)
    expect(json['data']['id']).to eq '55599'
    expect(json['data']['attributes']).to eq expected    
  end
end
