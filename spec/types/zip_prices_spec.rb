describe Buzzn::Types::ZipPrices do

  before :all do
    file = File.join('db', 'csv', "TEST_MINIMAL_GET_AG_2017ET_DTdot.csv")
    ZipToPrice.from_csv(file)

    CoreConfig.store Buzzn::Types::ZipPriceConfig.new(
        kwkg_aufschlag: 1.0,
        ab_la_v: 1.0,
        strom_nev: 1.0,
        stromsteuer: 1.0,
        eeg_umlage:  1.0,
        offshore_haftung: 1.0,
        deckungs_beitrag: 1.0,
        energie_preis: 1.0,
        vat: 12.0,
        yearly_euro_intern: 0.0
    )
  end

  it 'max price when there is more then one DSO' do
    prices = Buzzn::Types::ZipPrices.new(zip: 1468, type: 'single', annual_kwh: 1)
    expect(prices.max_price.price.dso).to eq 'ENSO Netz GmbH'
    expect(ZipToPrice.by_zip(1468).count).to eq 2
  end

  it 'max price when there is exactly one DSO' do
    prices = Buzzn::Types::ZipPrices.new(zip: 1445, type: 'single', annual_kwh: 1)
    expect(prices.max_price.price.dso).to eq 'Stadtwerke Elbtal GmbH'
    expect(ZipToPrice.by_zip(1445).count).to eq 1
  end
end
