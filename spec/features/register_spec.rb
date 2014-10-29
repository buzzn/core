require 'spec_helper'


feature 'Register' do
  describe 'try to manage registers', :js do

    before do
      Fabricate(:metering_point_operator, name: 'Discovergy')
      @user = Fabricate(:christian)
      @location = Fabricate(:roentgenstrasse11)
      @user.add_role :admin
      @user.contracting_party = Fabricate(:contracting_party)
      @user.contracting_party.electricity_supplier_contracts << @location.metering_point.electricity_supplier_contracts.first

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to edit register' do
      visit "/metering_points/#{@location.metering_point.slug}/#tab_meter"

      expect(page).to have_content('Easymeter')

      find(".meter").find(".block").first(".header").find(".btn").click

      find(:css, "input[id^='meter_registers_attributes_'][id$='_obis_index']").set("12345")

      click_on 'Update Meter'

      expect(find(".registers")).to have_content('12345')
    end

    it 'try to add and remove register' do
      visit "/metering_points/#{@location.metering_point.slug}/#tab_meter"

      expect(page).to have_content('Easymeter')

      find(".meter").find(".block").first(".header").find(".btn").click

      click_on 'Add Register'

      find("#registers").all(".nested-fields").last.find(:css, "input[id^='meter_registers_attributes_'][id$='_obis_index']").set("12345678")
      find("#registers").all(".nested-fields").last.find(:css, "select[id^='meter_registers_attributes_'][id$='_mode']").find(:xpath, 'option[2]').select_option

      click_on 'Update Meter'

      expect(find(".registers")).to have_content('12345678')

      #visit "/metering_points/#{@location.metering_point.slug}/#tab_meter" #reload to make css selector visible

      find(".meter").find(".block").first(".header").find(".btn").click
      find("#registers").all(".nested-fields").first.click_on 'Remove Register'

      click_on 'Update Meter'

      expect(find(".registers")).not_to have_content('12345678')
    end
  end
end