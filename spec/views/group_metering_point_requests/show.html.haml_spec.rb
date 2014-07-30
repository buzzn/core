require 'rails_helper'

RSpec.describe "group_metering_point_requests/show", :type => :view do
  before(:each) do
    @group_metering_point_request = assign(:group_metering_point_request, GroupMeteringPointRequest.create!(
      :sender_id => 1,
      :receiver_id => 2,
      :sender_mp_id => 3,
      :status => "Status"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Status/)
  end
end
