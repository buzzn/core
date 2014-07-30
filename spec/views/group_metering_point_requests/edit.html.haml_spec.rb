require 'rails_helper'

RSpec.describe "group_metering_point_requests/edit", :type => :view do
  before(:each) do
    @group_metering_point_request = assign(:group_metering_point_request, GroupMeteringPointRequest.create!(
      :sender_id => 1,
      :receiver_id => 1,
      :sender_mp_id => 1,
      :status => "MyString"
    ))
  end

  it "renders the edit group_metering_point_request form" do
    render

    assert_select "form[action=?][method=?]", group_metering_point_request_path(@group_metering_point_request), "post" do

      assert_select "input#group_metering_point_request_sender_id[name=?]", "group_metering_point_request[sender_id]"

      assert_select "input#group_metering_point_request_receiver_id[name=?]", "group_metering_point_request[receiver_id]"

      assert_select "input#group_metering_point_request_sender_mp_id[name=?]", "group_metering_point_request[sender_mp_id]"

      assert_select "input#group_metering_point_request_status[name=?]", "group_metering_point_request[status]"
    end
  end
end
