require 'rails_helper'

RSpec.describe "servicing_contracts/show", :type => :view do
  before(:each) do
    @servicing_contract = assign(:servicing_contract, ServicingContract.create!(
      :tariff => "Tariff",
      :status => "Status",
      :signing_user => "Signing User",
      :terms => false,
      :confirm_pricing_model => false,
      :power_of_attorney => false,
      :forecast_watt_hour_pa => "Forecast Watt Hour Pa",
      :price_cents => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Tariff/)
    expect(rendered).to match(/Status/)
    expect(rendered).to match(/Signing User/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Forecast Watt Hour Pa/)
    expect(rendered).to match(/1/)
  end
end
