describe ZipToPriceRoda do

  def app
    ZipToPriceRoda # this defines the active application for this test
  end

  before :all do
    file = File.join('db', 'csv', "TEST_MINIMAL_GET_AG_2017ET_DTdot.csv")
    ZipToPrice.from_csv(file)

    CoreConfig.store Buzzn::Types::ZipPriceConfig.new(
        kwkg_aufschlag: 0.445,
        ab_la_v: 0.006,
        strom_nev: 0.388,
        stromsteuer: 2.050,
        eeg_umlage:  6.88,
        offshore_haftung: -0.028,
        deckungs_beitrag: 1.00,
        energie_preis: 5.00,
        vat: 1.19,
        yearly_euro_intern: 41.64
    )
  end

  context 'POST' do

    let(:wrong_json) do
      {
        "errors"=>[
          {"parameter"=>"type",
           "detail"=>"must be one of: single, double, smart"},
          {"parameter"=>"zip", "detail"=>"must be an integer"},
          {"parameter"=>"annual_kwh", "detail"=>"must be an integer"}
        ]
      }
    end

    let(:not_found_json) do
      {
        "errors"=>[{"parameter"=>"zip", "detail"=>"no price for zip found"}]
      }
    end

    let(:price_json) do
      {
        "baseprice_cents_per_month"=>841,
        "energyprice_cents_per_kilowatt_hour"=>30,
        "total_cents_per_month"=>3926
      }
    end

    it '422' do
      POST '', nil,
           zip: 'ip164ex',
           annual_kwh: 'a lot',
           type: 'superduper'

      expect(response).to have_http_status(422)
      expect(json.to_yaml).to eq wrong_json.to_yaml
    end

    it '404' do
      POST '', nil,
           zip: 1,
           annual_kwh: 1234,
           type: 'single'

      expect(response).to have_http_status(404)
      expect(json.to_yaml).to eq not_found_json.to_yaml
    end

    it '200' do
      POST '', nil,
           zip: 1217,
           annual_kwh: 1234,
           type: 'double'

      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq price_json.to_yaml
    end
  end
end
