require 'spec_helper'


feature 'GroupMeteringPointRequest' do
  describe 'try to manage group_metering_point_requests', :js do

    before do
      @user = Fabricate(:user)
      @metering_point = Fabricate(:mp_60138988, uid: "1234567890")
      @user.add_role(:manager, @metering_point)
      @group = Fabricate(:group, metering_points: [ @metering_point ])
      @user.add_role :manager, @group

      @user2 = Fabricate(:user)
      @metering_point2 = Fabricate(:mp_60009269, uid: "0987654321")
      @metering_point2.users << @user2
      @user2.add_role(:manager, @metering_point2)

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
    end

    it 'will be signed in', :retry => 3 do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create membership', :retry => 3 do
      visit "/groups/#{@group.slug}"
      click_on 'Membership'
      click_on "Join This Group"

      expect(page).to have_content('Sent Group Metering Point Request')

      find(".navbar-content").click_link "#{@user2.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      visit "/groups/#{@group.slug}"

      expect(page).to have_content('New Group Metering Point Request')

      find(".bs-callout").click_on "Accept"
      expect(page).to have_content('Accepted Group Metering Point Request')

      #visit "/groups/#{@group.slug}"

      #expect(page).to have_content("#{@user2.name}")
    end

    it 'will fail to create membership', :retry => 3 do
      visit "/groups/#{@group.slug}"
      click_on 'Membership'
      click_on "Join This Group"          #translation 'en' doesnt accept attributes yet

      expect(page).to have_content('Sent Group Metering Point Request')

      find(".navbar-content").click_link "#{@user2.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      visit "/groups/#{@group.slug}"

      expect(page).to have_content('New Group Metering Point Request')

      find(".bs-callout").click_on "Reject"
      expect(page).to have_content('Rejected Group Metering Point Request')

      #visit "/groups/#{@group.slug}"

      #expect(page).to have_content("#{@user2.name}")
    end

    it 'try to cancel membership', :retry => 1 do
      @group.metering_points << @metering_point2

      visit "/groups/#{@group.slug}"

      #expect(page).to have_content("#{@user2.profile.name}")
      click_on 'Membership'
      click_on "Leave This Group"          #translation 'en' doesnt accept attributes yet

      #visit "/groups/#{@group_home_of_the_brave.slug}/cancel_membership?metering_point_id=#{@location2.metering_point.id}" #click doesn't work here due to confirmation

      expect(find("#page-content")).not_to have_content("#{@user2.profile.name}")
      click_on 'Membership'
      expect(page).to have_content('Join This Group')

      visit "/profiles/#{@user2.profile.slug}"
      expect(page).not_to have_content("#{@group.name}")
    end
  end
end