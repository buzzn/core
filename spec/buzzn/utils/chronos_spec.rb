describe Buzzn::Utils::Chronos do

  it 'calculates the right timespan in months' do
    date_1 = Date.new(2016, 1, 1)
    date_2 = Date.new(2016, 12, 31)
    result = Buzzn::Utils::Chronos.timespan_in_months(date_1, date_2)
    expect(result).to eq 12

    (1..12).each do |i|
      date_2 = Date.new(2016, i, 1).end_of_month
      result = Buzzn::Utils::Chronos.timespan_in_months(date_1, date_2)
      result_swapped = Buzzn::Utils::Chronos.timespan_in_months(date_2, date_1)
      expect(result).to eq i
      expect(result).to eq result_swapped
    end

    (1..31).each do |i|
      date_2 = Date.new(2016, 12, i)
      result = Buzzn::Utils::Chronos.timespan_in_months(date_1, date_2)
      result_swapped = Buzzn::Utils::Chronos.timespan_in_months(date_2, date_1)
      expect(result).to eq i >= 21 ? 12 : (i >=10 ? 11.5 : 11)
      expect(result).to eq result_swapped
    end
  end
end

