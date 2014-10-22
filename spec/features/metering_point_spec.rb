require 'spec_helper'


feature 'MeteringPoint' do
  describe 'try to manage metering_points', :js do

    before do
      @user = Fabricate(:user)
      @location = Fabricate(:location, metering_point: nil)
      @user.add_role :manager, @location

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create metering_point' do
      visit "/locations/#{@location.slug}"
      expect(page).to have_content('You Have No Metering Point')
      click_on 'Create New Metering Point'

      fill_in :metering_point_address_addition,       with: 'Wohnung'
      fill_in :metering_point_uid,                    with: 'DE123456789012345678901'

      click_on 'continue'
      expect(page).to have_content('New Meter')

      select 'smart_meter',                                 from: 'meter_manufacturer_name'
      fill_in :meter_manufacturer_product_name,             with: 'Easymeter'
      fill_in :meter_manufacturer_product_serialnumber,     with: '123456'
      select  'in',                                         from: 'meter_registers_attributes_0_mode'

      click_on 'continue'
      expect(page).to have_content('metering_point_created_successfully')

      click_on 'Details'
      expect(page).to have_content('Day To Hours')
      expect(page).to have_content('Wohnung')

      click_on 'Meter'
      expect(page).to have_content('Meter')
      expect(page).to have_content('Easymeter')
      expect(page).to have_content('Registers')

      click_on 'Contracts'
      expect(page).to have_content('Add Metering Point Operator Contract')
    end

    it 'will fail to create metering_point' do
      visit "/locations/#{@location.slug}"
      click_on 'Create New Metering Point'

      fill_in :metering_point_address_addition,       with: ''
      fill_in :metering_point_uid,                    with: 'DE123456789012345678901'

      click_on 'continue'
      expect(page).to have_content("can't be blank")

      fill_in :metering_point_address_addition,       with: 'Wohnung'
      fill_in :metering_point_uid,                    with: 'DE12345678901234567890123456789012345'

      click_on 'continue'
      expect(page).to have_content('is too long')

      fill_in :metering_point_address_addition,       with: 'Wohnung'
      fill_in :metering_point_uid,                    with: 'DE123456789012345678901'

      click_on 'continue'
      expect(page).to have_content('Manufacturer')

      select 'smart_meter',                                 from: 'meter_manufacturer_name'
      fill_in :meter_manufacturer_product_name,             with: 'Easymeter'
      fill_in :meter_manufacturer_product_serialnumber,     with: '123456'

      click_on 'continue'
      expect(page).not_to have_content('metering_point_created_successfully')

      select 'smart_meter',                                 from: 'meter_manufacturer_name'
      fill_in :meter_manufacturer_product_name,             with: 'Easymeter'
      fill_in :meter_manufacturer_product_serialnumber,     with: ''
      select  'in',                                         from: 'meter_registers_attributes_0_mode'

      click_on 'continue'
      expect(page).not_to have_content('metering_point_created_successfully')
    end


  end

end