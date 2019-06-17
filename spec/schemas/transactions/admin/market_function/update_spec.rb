require 'buzzn/schemas/transactions/market_function/update'

describe 'Schemas::Transactions::MarketFunction::Update' do

  let(:org) do
    create(:organization, :electricity_supplier, :transmission_system_operator)
  end

  let(:es_mf) do
    org.market_functions.where(:function => 'electricity_supplier').first
  end

  let(:tso_mf) do
    org.market_functions.where(:function => 'transmission_system_operator').first
  end

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


  context 'function' do

    subject { Schemas::Transactions::MarketFunction.update_for(tso_mf, org) }

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
