require 'rails_helper'

RSpec.describe "servicing_contracts/new", :type => :view do
  before(:each) do
    assign(:servicing_contract, ServicingContract.new(
      :tariff => "MyString",
      :status => "MyString",
      :signing_user => "MyString",
      :terms => false,
      :confirm_pricing_model => false,
      :power_of_attorney => false,
      :forecast_watt_hour_pa => "MyString",
      :price_cents => 1
    ))
  end

  it "renders new servicing_contract form" do
    render

    assert_select "form[action=?][method=?]", servicing_contracts_path, "post" do

      assert_select "input#servicing_contract_tariff[name=?]", "servicing_contract[tariff]"

      assert_select "input#servicing_contract_status[name=?]", "servicing_contract[status]"

      assert_select "input#servicing_contract_signing_user[name=?]", "servicing_contract[signing_user]"

      assert_select "input#servicing_contract_terms[name=?]", "servicing_contract[terms]"

      assert_select "input#servicing_contract_confirm_pricing_model[name=?]", "servicing_contract[confirm_pricing_model]"

      assert_select "input#servicing_contract_power_of_attorney[name=?]", "servicing_contract[power_of_attorney]"

      assert_select "input#servicing_contract_forecast_watt_hour_pa[name=?]", "servicing_contract[forecast_watt_hour_pa]"

      assert_select "input#servicing_contract_price_cents[name=?]", "servicing_contract[price_cents]"
    end
  end
end
