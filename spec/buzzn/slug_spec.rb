describe Buzzn::Slug do


  it "makes slugs" do
    expect(Buzzn::Slug.new("Häberlstraße 15")).to eq 'häberlstraße'
    expect(Buzzn::Slug.new("wagnisART - Europa + Amerika")).to eq 'wagnisart-europa-amerika'
    expect(Buzzn::Slug.new("Heigelstraße 27B")).to eq 'heigelstraße'
    expect(Buzzn::Slug.new("Hühnefeldstraße 6-8")).to eq 'hühnefeldstraße'
    expect(Buzzn::Slug.new("Gertrud-Grunow-Straße 45 - WA12")).to eq 'gertrud-grunow-straße'
    expect(Buzzn::Slug.new("Cherubinistr. 4-8 / Destouchesstr. 39")).to eq 'cherubinistr-destouchesstr'
    expect(Buzzn::Slug.new("L.O.F.T.")).to eq 'loft'
  end
end
