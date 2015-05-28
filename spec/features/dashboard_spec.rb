require 'spec_helper'


feature 'Dashboard' do
  describe 'try to manage dashboards', :js do

    before do
      @user = Fabricate(:christian)
      @metering_point = Fabricate(:metering_point)
      @meter = Fabricate(:meter, smart: true, online: true, init_reading: true)
      @metering_point.meter = @meter
      @metering_point.save
      @user.add_role :admin

      @user2 = Fabricate(:user)

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to add metering_point', :retry => 3 do
      visit "/metering_points/#{@metering_point.id}"

      find(".add-to-dashboard").find(".btn").click

      expect(page.has_css?(".add-to-dashboard", visible: false))

      click_on "Dashboard"

      expect(find(".metering_points")).to have_content("#{@metering_point.name}")
    end

    it 'try to display metering_point', :retry => 3 do
      @user.dashboard.metering_points << @metering_point

      visit "/dashboards/#{@user.dashboard.id}"

      click_on 'Start Display'

      expect(find(".dashboard-chart")).to have_content('Zeit')
      expect(find(".metering_point")).to have_content('Stop Display')
    end

    it 'will not be allowed to view dashboard', :retry => 3 do
      @user.dashboard.metering_points << @metering_point

      find(".navbar-content").click_link "#{@user.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      visit "/dashboards/#{@user.dashboard.id}"

      expect(page).to have_content('Access Denied')
    end

    it 'try to remove metering_point from chart', :retry => 3 do
      @user.dashboard.metering_points << @metering_point
      @dashboard_metering_point = DashboardMeteringPoint.where(dashboard_id: @user.dashboard.id, metering_point_id: @metering_point.id).first
      @dashboard_metering_point.displayed = true
      @dashboard_metering_point.save

      visit "/dashboards/#{@user.dashboard.id}"

      click_on 'Stop Display'

      expect(find(".dashboard-chart")).not_to have_content('Zeit')
      expect(find(".metering_point")).to have_content('Start Display')
    end

    it 'try to remove metering_point from dashboard', :retry => 1 do
      @user.dashboard.metering_points << @metering_point

      visit "/dashboards/#{@user.dashboard.id}"

      click_on 'Remove From Dashboard'

      expect(page.has_css?(".metering_point", visible: false))
      expect(page).not_to have_content("#{@metering_point.name}")

      visit "/metering_points/#{@metering_point.id}"

      expect(page).to have_content("Add To Dashboard")
    end
  end
end