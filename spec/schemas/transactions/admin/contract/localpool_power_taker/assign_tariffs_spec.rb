describe 'Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::AssignTariffs' do

  subject { Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::AssignTariffs }

  let(:valid_params) do
    {
      :updated_at => Date.today.to_json,
      :tariff_ids => [1, 2, 3, 4, 5, 6]
    }
  end

  let(:invalid_params_1) do
    {
      :updated_at => Date.today.to_json,
      :tariff_ids => 'foo'
    }
  end

  let(:invalid_params_2) do
    {
      :updated_at => Date.today.to_json,
      :tariff_ids => [1, 2, 3, 4, 5, 'a']
    }
  end

  it 'is valid' do
    expect(subject.(valid_params)).to be_success
  end

  context 'wrong type' do
    it 'is invalid' do
      expect(subject.(invalid_params_1)).to be_failure
    end
  end

  context 'wrong type in array' do
    it 'is invalid' do
      expect(subject.(invalid_params_2)).to be_failure
    end
  end

end
