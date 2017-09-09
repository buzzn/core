describe Buzzn::Types::ZipPrice do

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

  let(:price) { ZipToPrice.first }

  it 'calculates prices for type: single' do
    zip_price = Buzzn::Types::ZipPrice.new price: price, type: 'single', annual_kwh: 1

    expect(zip_price.raw_unit_cents_netto).to eq price.unitprice_cents_kwh_et
    unit_price = price.unitprice_cents_kwh_et + 8 + price.ka
    expect(zip_price.unit_cents_netto).to eq unit_price
    expect(zip_price.yearly_euro_netto).to eq price.measurement_euro_year_et + price.baseprice_euro_year_et

    expect(zip_price.baseprice_cents_per_month).to eq ((price.measurement_euro_year_et + price.baseprice_euro_year_et) * 100).to_i
    expect(zip_price.energyprice_cents_per_kilowatt_hour).to eq (unit_price * 12).to_i
    expect(zip_price.total_cents_per_month).to eq ((price.measurement_euro_year_et + price.baseprice_euro_year_et) * 100 + unit_price).to_i
  end

  it 'calculates prices for type: double' do
    zip_price = Buzzn::Types::ZipPrice.new price: price, type: 'double', annual_kwh: 1

    expect(zip_price.raw_unit_cents_netto).to eq price.unitprice_cents_kwh_dt
    unit_price = price.unitprice_cents_kwh_dt + 8 + price.ka
    expect(zip_price.unit_cents_netto).to eq unit_price
    expect(zip_price.yearly_euro_netto).to eq price.measurement_euro_year_dt + price.baseprice_euro_year_dt

    expect(zip_price.baseprice_cents_per_month).to eq ((price.measurement_euro_year_dt + price.baseprice_euro_year_dt) * 100).to_i
    expect(zip_price.energyprice_cents_per_kilowatt_hour).to eq (unit_price * 12).to_i
    expect(zip_price.total_cents_per_month).to eq ((price.measurement_euro_year_dt + price.baseprice_euro_year_dt) * 100 + unit_price).to_i
  end

  it 'calculates prices for type: smart' do
    zip_price = Buzzn::Types::ZipPrice.new price: price, type: 'smart', annual_kwh: 1

    expect(zip_price.raw_unit_cents_netto).to eq price.unitprice_cents_kwh_et
    unit_price = price.unitprice_cents_kwh_et + 8 + price.ka
    expect(zip_price.unit_cents_netto).to eq unit_price
    expect(zip_price.yearly_euro_netto).to eq price.baseprice_euro_year_et

    expect(zip_price.baseprice_cents_per_month).to eq (price.baseprice_euro_year_et * 100).to_i
    expect(zip_price.energyprice_cents_per_kilowatt_hour).to eq (unit_price * 12).to_i
    expect(zip_price.total_cents_per_month).to eq (price.baseprice_euro_year_et * 100 + unit_price).to_i
  end
end
