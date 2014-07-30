require 'rails_helper'

RSpec.describe "group_metering_point_requests/index", :type => :view do
  before(:each) do
    assign(:group_metering_point_requests, [
      GroupMeteringPointRequest.create!(
        :sender_id => 1,
        :receiver_id => 2,
        :sender_mp_id => 3,
        :status => "Status"
      ),
      GroupMeteringPointRequest.create!(
        :sender_id => 1,
        :receiver_id => 2,
        :sender_mp_id => 3,
        :status => "Status"
      )
    ])
  end

  it "renders a list of group_metering_point_requests" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "Status".to_s, :count => 2
  end
end
