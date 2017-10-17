describe "Contract Sub Models" do
  
  let(:power_taker_contract_move_in) do
    Fabricate(:power_taker_contract_move_in)
  end

  let(:power_taker_contract_move_in_for_organization) do
    Fabricate(:power_taker_contract_move_in_for_organization)
  end

  let(:power_taker_contract_old_contract) do
    Fabricate(:power_taker_contract_old_contract)
  end

  let(:power_taker_contract_old_contract_for_organization) do
    Fabricate(:power_taker_contract_old_contract_for_organization)
  end

  let(:power_giver_contract_for_organization) do
    Fabricate(:power_giver_contract_for_organization)
  end

  let(:power_giver_contract) do
    Fabricate(:power_giver_contract)
  end

  let(:metering_point_operator_contract_of_localpool) do
    Fabricate(:metering_point_operator_contract_of_localpool)
  end

  let(:metering_point_operator_contract_of_localpool_for_organization) do
    Fabricate(:metering_point_operator_contract_of_localpool_for_organization)
  end

  let(:metering_point_operator_contract_of_register) do
    Fabricate(:metering_point_operator_contract_of_register)
  end

  let(:metering_point_operator_contract_of_register_for_organization) do
    Fabricate(:metering_point_operator_contract_of_register_for_organization)
  end

  let(:localpool_power_taker_contract) do
    Fabricate(:localpool_power_taker_contract)
  end

  let(:localpool_power_taker_contract_for_organization) do
    Fabricate(:localpool_power_taker_contract_for_organization)
  end

  let(:localpool_processing_contract) do
    Fabricate(:localpool_processing_contract)
  end

  let(:localpool_processing_contract_for_organization) do
    Fabricate(:localpool_processing_contract_for_organization)
  end

  [:power_taker_contract_move_in,
   :power_taker_contract_move_in_for_organization,
   :power_taker_contract_old_contract,
   :power_taker_contract_old_contract_for_organization,
   :power_giver_contract,
   :power_giver_contract_for_organization,
   :metering_point_operator_contract_of_localpool,
   :metering_point_operator_contract_of_localpool_for_organization,
   :metering_point_operator_contract_of_register,
   :metering_point_operator_contract_of_register_for_organization,
   :localpool_power_taker_contract,
   :localpool_power_taker_contract_for_organization,
   :localpool_processing_contract,
   :localpool_processing_contract_for_organization].each do |c|

    it "creates valid #{c}" do
      contract = send c
      expect(contract.valid?).to eq true
    end
  end
end
