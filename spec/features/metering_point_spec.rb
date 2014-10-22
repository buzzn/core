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
      page.should have_content('Signed in successfully.')
    end

    it 'try to create metering_point' do
      visit "/locations/#{@location.slug}"
      page.should have_content('You Have No Metering Point')
      click_on 'Create New Metering Point'

      fill_in :metering_point_address_addition,       with: 'Wohnung'
      fill_in :metering_point_uid,                    with: 'DE123456789012345678901'

      click_on 'continue'
      page.should have_content('New Meter')

      select 'smart_meter',                           from: 'meter_manufacturer_name'
      fill_in :meter_manufacturer_product_name,             with: 'Easymeter'
      fill_in :meter_manufacturer_product_serialnumber,     with: '123456'
      select  'in',                                   from: 'meter_registers_attributes_0_mode'

      click_on 'continue'
      page.should have_content('metering_point_created_successfully')
    end


  end

end