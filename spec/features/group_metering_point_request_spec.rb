require 'spec_helper'


feature 'GroupMeteringPointRequest' do
  describe 'try to manage group_metering_point_requests', :js do

    before do
      @user = Fabricate(:justus)
      @fichtenweg8 = Fabricate(:fichtenweg8)

      mp_z1 = Fabricate(:mp_z1)
      mp_z2 = Fabricate(:mp_z2)
      mp_z3 = Fabricate(:mp_z3)
      mp_z4 = Fabricate(:mp_z4)
      mp_z5 = Fabricate(:mp_z5)

      mp_z2.update_attribute :parent, mp_z1
      mp_z3.update_attribute :parent, mp_z1
      mp_z4.update_attribute :parent, mp_z1
      mp_z5.update_attribute :parent, mp_z1

      @fichtenweg8.metering_point = mp_z1

      @device        = Fabricate(:dach_pv_justus)
      @user.add_role :manager, @device
      @user.add_role :manager, @fichtenweg8

      @group_home_of_the_brave = Fabricate(:group_home_of_the_brave, metering_points: [@fichtenweg8.metering_point], assets: [])
      @user.add_role :manager, @group_home_of_the_brave

      @user2 = Fabricate(:user)
      @location2 = Fabricate(:location)
      @user2.add_role :manager, @location2
      @user2.contracting_party = Fabricate(:contracting_party)
      @user2.contracting_party.electricity_supplier_contracts << @location2.metering_point.electricity_supplier_contracts.first

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create membership', :retry => 3 do
      visit "/groups/#{@group_home_of_the_brave.slug}"
      click_on 'Membership'
      click_on "Join This Group With Metering Point"          #translation 'en' doesnt accept attributes

      expect(page).to have_content('Sent Group Metering Point Request')

      visit "/profiles/#{@user2.profile.slug}"        #nessessary to enable matching to .nav
      find(".nav").click_link "#{@user2.name}"
      click_on 'Logout'
      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      visit "/groups/#{@group_home_of_the_brave.slug}"

      expect(page).to have_content('New Group Metering Point Request')

      find(".bs-callout").click_on "Accept"
      expect(page).to have_content('Accepted Group Metering Point Request')

      expect(find("#metering_points")).to have_content("#{@location2.metering_point.decorate.name}")
    end

    it 'will fail to create membership', :retry => 3 do
      visit "/groups/#{@group_home_of_the_brave.slug}"
      click_on 'Membership'
      click_on "Join This Group With Metering Point"          #translation 'en' doesnt accept attributes yet

      expect(page).to have_content('Sent Group Metering Point Request')

      visit "/profiles/#{@user2.profile.slug}"        #nessessary to enable matching to .nav
      find(".nav").click_link "#{@user2.name}"
      click_on 'Logout'
      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      visit "/groups/#{@group_home_of_the_brave.slug}"

      expect(page).to have_content('New Group Metering Point Request')

      find(".bs-callout").click_on "Reject"
      expect(page).to have_content('Rejected Group Metering Point Request')

      expect(find("#metering_points")).not_to have_content("#{@location2.metering_point.decorate.name}")
    end

    it 'try to cancel membership', :retry => 3 do
      @location2.metering_point.group = @group_home_of_the_brave
      @location2.metering_point.save

      visit "/groups/#{@group_home_of_the_brave.slug}"
      click_on 'Membership'
      expect(page).to have_content("Leave This Group With Metering Point")
      #click_on "Leave This Group With Metering Point"          #translation 'en' doesnt accept attributes yet

      visit "/groups/#{@group_home_of_the_brave.slug}/cancel_membership?metering_point_id=#{@location2.metering_point.id}" #click doesn't work here due to confirmation

      expect(find("#metering_points")).not_to have_content("#{@location2.metering_point.decorate.name}")
      click_on 'Membership'
      expect(page).to have_content('Join This Group With Metering Point')

      visit "/metering_points/#{@location2.metering_point.slug}"
      expect(page).not_to have_content('Belongs To Group')
    end
  end
end