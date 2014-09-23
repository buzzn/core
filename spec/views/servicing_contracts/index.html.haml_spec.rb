require 'rails_helper'

RSpec.describe "servicing_contracts/index", :type => :view do
  before(:each) do
    assign(:servicing_contracts, [
      ServicingContract.create!(
        :tariff => "Tariff",
        :status => "Status",
        :signing_user => "Signing User",
        :terms => false,
        :confirm_pricing_model => false,
        :power_of_attorney => false,
        :forecast_watt_hour_pa => "Forecast Watt Hour Pa",
        :price_cents => 1
      ),
      ServicingContract.create!(
        :tariff => "Tariff",
        :status => "Status",
        :signing_user => "Signing User",
        :terms => false,
        :confirm_pricing_model => false,
        :power_of_attorney => false,
        :forecast_watt_hour_pa => "Forecast Watt Hour Pa",
        :price_cents => 1
      )
    ])
  end

  it "renders a list of servicing_contracts" do
    render
    assert_select "tr>td", :text => "Tariff".to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
    assert_select "tr>td", :text => "Signing User".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Forecast Watt Hour Pa".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
