# coding: utf-8
describe CoreConfig do


  let(:config) do
    Buzzn::Types::ZipPriceConfig.new(
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

  it 'stores and loads config' do
    CoreConfig.store(config)
    c = CoreConfig.load(Buzzn::Types::ZipPriceConfig)
    expect(c).to eq config
    
    expect(CoreConfig.count).to eq 10
  end

  it 'updates and loads config' do
    CoreConfig.store(config)

    conf = Buzzn::Types::ZipPriceConfig.new(
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
    CoreConfig.store(conf)

    c = CoreConfig.load(Buzzn::Types::ZipPriceConfig)
    expect(c).to eq conf

    expect(CoreConfig.count).to eq 10
  end
end
