describe "Contract Sub Models" do
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
   :localpool_processing_contract_for_organization].each do |contract_fabricator|

    it "creates valid contract: #{contract_fabricator}" do
      contract = Fabricate.build(contract_fabricator)
      expect(contract).to be_valid
    end
  end
end
