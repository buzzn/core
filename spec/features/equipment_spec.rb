require 'spec_helper'


feature 'Equipment' do
  describe 'try to manage equipments', :js do

    before do
      Fabricate(:metering_point_operator, name: 'Discovergy')
      @user = Fabricate(:christian)
      @metering_point = Fabricate(:mp_60009269)
      @user.add_role :admin
      @user.contracting_party = Fabricate(:contracting_party)

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    # it 'try to create equipment', :retry => 1  do #**********Equipment is currently not visible in the app********************
    #   @metering_point.meter.equipments = []
    #   @metering_point.meter.save

    #   visit "/meters/#{@metering_point.meter.id}"

    #   expect(page).to have_content('Easy Meter')

    #   click_on 'Edit'

      # click_on 'Add Equipment'

      # find(:css, "input[id^='meter_equipments_attributes_'][id$='_manufacturer_name']").set("Discovergy")
      # find(:css, "input[id^='meter_equipments_attributes_'][id$='_manufacturer_product_name']").set("Meteroid")
      # find(:css, "input[id^='meter_equipments_attributes_'][id$='_manufacturer_product_serialnumber']").set("123456")
      # find(:css, "input[id^='meter_equipments_attributes_'][id$='_device_kind']").set("Kommunikationsmodul")
      # find(:css, "input[id^='meter_equipments_attributes_'][id$='_device_type']").set("Nochwas")
      # find(:css, "input[id^='meter_equipments_attributes_'][id$='_ownership']").set("buzzn")
      # find(:css, "input[id^='meter_equipments_attributes_'][id$='_converter_constant']").set(1)

      # click_on 'Update Meter'

      # expect(find(".equipments")).to have_content('Discovergy')
    #end

    # it 'try to delete equipment', :retry => 3 do
    #   visit "/metering_points/#{@location.metering_point.slug}/#meter"

    #   expect(page).to have_content('Easymeter')

    #   find(".meter").find(".block").first(".header").first(".btn").trigger('click')

    #   click_on 'Remove Equipment'

    #   click_on 'Update Meter'

    #   expect(find(".equipments")).not_to have_content('Discovergy')
    # end
  end
end