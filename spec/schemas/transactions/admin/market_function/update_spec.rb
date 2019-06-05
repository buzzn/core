require 'buzzn/schemas/transactions/market_function/update'

describe 'Schemas::Transactions::MarketFunction::Update' do

  let(:org_naked) { create(:organization, :electricity_supplier) }
  let(:market_function) { org_naked.market_functions.first }

  let(:invalid_params_1) do
    {
      :updated_at => Date.today.to_json,
      :function => 'electricity_supplier'
    }
  end

  let(:valid_params_1) do
    {
      :updated_at => Date.today.to_json,
      :function => 'metering_service_provider'
    }
  end

  subject { Schemas::Transactions::MarketFunction.update_for(market_function, org_naked) }

  context 'function' do

    it 'does not allow the function' do
      expect(subject.(invalid_params_1)).to be_failure
      res = subject.(invalid_params_1)
      expect(res.errors).to eql ({:function => ['must be one of: distribution_system_operator, metering_point_operator, metering_service_provider, other, power_giver, power_taker, transmission_system_operator'] })
    end

    it 'allows the function' do
      expect(subject.(valid_params_1)).to be_success
    end

  end
end
