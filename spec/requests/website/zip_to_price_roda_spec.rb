require 'buzzn/types/zip_price_config'

describe Website::ZipToPriceRoda, :request_helper do

  def app
    Website::ZipToPriceRoda # this defines the active application for this test
  end

  before :all do
    file = File.join('db', 'csv', 'GetAG_2018_ET_minimal.csv')
    ZipToPrice.from_csv(file, true)
    file = File.join('db', 'csv', 'GetAG_2018_DT_minimal.csv')
    ZipToPrice.from_csv(file, false)

    CoreConfig.store Types::ZipPriceConfig.new(
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
      { 'errors'=>{
        'type'=>['must be one of: single, double, smart'],
        'zip'=>['size cannot be greater than 5'],
        'annual_kwh'=>['must be an integer']}
      }
    end

    let(:not_found_json) do
      {
        'zip'=>['no price for zip found']
      }
    end

    let(:price_json) do
      {
        'baseprice_cents_per_month'=>830,
        'energyprice_cents_per_kilowatt_hour'=>29.2,
        'total_cents_per_month'=>3833
      }
    end

    it '422' do
      POST '', nil,
           zip: 'ip164ex',
           annual_kwh: 'a lot',
           type: 'superduper'

      expect(response).to have_http_status(422)
      expect(json.to_yaml).to eq wrong_json.to_yaml

      POST '', nil,
           zip: '1',
           annual_kwh: 1234,
           type: 'single'

      expect(response).to have_http_status(422)
      expect(json.to_yaml).to eq not_found_json.to_yaml
    end

    it '200' do
      POST '', nil,
           zip: '01337',
           annual_kwh: 1234,
           type: 'double'

      expect(response).to have_http_status(200)
      expect(json.to_yaml).to eq price_json.to_yaml
    end

  end
end
