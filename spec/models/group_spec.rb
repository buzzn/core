# coding: utf-8
describe "Group Model" do

  it 'filters group' do
    Fabricate(:buzzn_metering)
    group = Fabricate(:group_home_of_the_brave)
    Fabricate(:group_karins_pv_strom)

    [group.name, group.description].each do |val|
      [val, val.upcase, val.downcase, val[0..4], val[-4..-1]].each do |value|
        groups = Group.filter(value)
        expect(groups.first).to eq group
      end
    end
  end


  it 'can not find anything' do
    Fabricate(:buzzn_metering)
    Fabricate(:group_hof_butenland)
    groups = Group.filter('Der Clown ist müde und geht nach Hause.')
    expect(groups.size).to eq 0
  end


  it 'filters group with no params' do
    Fabricate(:buzzn_metering)
    Fabricate(:group_wagnis4)
    Fabricate(:group_hof_butenland)
    Fabricate(:group_karins_pv_strom)

    groups = Group.filter(nil)
    expect(groups.size).to eq 3
  end
end
