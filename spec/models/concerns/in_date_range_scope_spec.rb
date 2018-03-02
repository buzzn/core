# Testing this scope separately with the example of contract.
describe 'InDateRangeScope' do

  let(:queried_range)      { Date.new(2018, 1, 1)..Date.new(2019, 1, 1) }
  let!(:contract)          { create(:contract, begin_date: contract_range.first, end_date: contract_range.last) }
  subject                  { Contract::Base.in_date_range(queried_range) }
  after                    { Contract::Base.delete_all }

  context 'when market location has one contract' do

    #
    # begin before date range
    #
    context 'when contract begins and ends before queried range' do
      let(:contract_range) { (queried_range.first - 1.month)..(queried_range.first - 1.day) }
      it { is_expected.to eq([]) }
    end

    context 'when contract begins before and ends on queried range start' do
      let(:contract_range) { (queried_range.first - 1.day)..queried_range.first }
      it { is_expected.to eq([]) }
    end

    context 'when contract begins before and ends in queried range' do
      let(:contract_range) { (queried_range.first - 1.day)..(queried_range.first + 1.day) }
      it { is_expected.to eq([contract]) }
    end

    context 'when contract begins before and ends after queried range' do
      let(:contract_range) { (queried_range.first - 1.day)..(queried_range.last + 1.day) }
      it { is_expected.to eq([contract]) }
    end

    #
    # begin in date range
    #
    context 'when contract begins in and ends in queried range' do
      let(:contract_range) { (queried_range.first + 1.day)..(queried_range.last - 1.day) }
      it { is_expected.to eq([contract]) }
    end

    context 'when contract begins in and ends after queried range' do
      let(:contract_range) { (queried_range.first + 1.day)..(queried_range.last + 1.day) }
      it { is_expected.to eq([contract]) }
    end

    #
    # begin on date range end
    #
    context 'when contract begins on queried range end' do
      let(:contract_range) { queried_range.last..(queried_range.last + 1.day) }
      it { is_expected.to eq([]) }
    end

    #
    # begin after date range
    #
    context 'when contract begins after queried range' do
      let(:contract_range) { (queried_range.last + 1.day)..(queried_range.last + 1.month) }
      it { is_expected.to eq([]) }
    end

  end

end
