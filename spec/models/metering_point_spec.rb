# coding: utf-8
describe "MeteringPoint Model" do

  it 'filters metering_point' do
    metering_point = Fabricate(:mp_urbanstr88)
    Fabricate(:mp_pv_karin)

    [metering_point.name,
     metering_point.address.city,
     metering_point.address.street_name].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        metering_points = MeteringPoint.filter(value)
        expect(metering_points.first).to eq metering_point
      end
    end
  end


  it 'can not find anything' do
    Fabricate(:mp_stefans_bhkw)
    metering_points = MeteringPoint.filter('Der Clown ist müde und geht nach Hause.')
    expect(metering_points.size).to eq 0
  end


  it 'filters metering_point with no params' do
    5.times { Fabricate(:mp_hof_butenland_wind) }

    metering_points = MeteringPoint.filter(nil)
    expect(metering_points.size).to eq 5
  end
end
