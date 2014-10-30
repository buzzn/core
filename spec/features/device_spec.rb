require 'spec_helper'


feature 'Device' do
  describe 'try to manage devices', :js do

    before do
      @user = Fabricate(:user)
      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create in device', :retry => 3  do
      visit "/profiles/#{@user.profile.slug}"
      click_on 'Devices'
      expect(page).to have_content('Add New In Device')
      click_on 'Add New In Device'
      expect(page).to have_content('Manufacturer')

      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_manufacturer_product_serialnumber,  with: '12345'
      fill_in :device_watt_peak,                          with: 200

      click_button 'submit'
      expect(page).to have_content('Belongs To')
    end

    it 'will fail to create in device', :retry => 3  do
      visit "/profiles/#{@user.profile.slug}"
      click_on 'Devices'
      expect(page).to have_content('Add New In Device')
      click_on 'Add New In Device'
      expect(page).to have_content('Manufacturer')

      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_manufacturer_product_serialnumber,  with: '12345'

      click_button 'submit'
      expect(page).to have_content("is not a number")

      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_manufacturer_product_serialnumber,  with: '12345'
      fill_in :device_watt_peak,                          with: "abc"

      click_button 'submit'
      expect(page).to have_content("is not a number")

      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_manufacturer_product_serialnumber,  with: '12345'
      fill_in :device_watt_peak,                          with: 200

      click_button 'submit'
      expect(page).to have_content('Belongs To')
    end

    it 'try to create out device', :retry => 3  do
      visit "/profiles/#{@user.profile.slug}"
      click_on 'Devices'
      expect(page).to have_content('Add New Out Device')
      click_on 'Add New Out Device'
      expect(page).to have_content('Manufacturer')

      select 'eeg',   from: 'device_law'
      select 'pv',    from: 'device_generator_type'
      select 'sun',   from: 'device_primary_energy'
      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_manufacturer_product_serialnumber,  with: '12345'
      fill_in :device_watt_peak,                          with: 2000

      click_button 'submit'
      expect(page).to have_content('Belongs To')
    end

    it 'will fail to create out device', :retry => 3 do
      visit "/profiles/#{@user.profile.slug}"
      click_on 'Devices'
      expect(page).to have_content('Add New Out Device')
      click_on 'Add New Out Device'
      expect(page).to have_content('Manufacturer')

      select 'pv',    from: 'device_generator_type'
      select 'sun',   from: 'device_primary_energy'
      select '',      from: 'device_law'
      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_manufacturer_product_serialnumber,  with: '12345'
      fill_in :device_watt_peak,                          with: 2000

      click_button 'submit'
      expect(page).to have_content("can't be blank")

      select '',      from: 'device_generator_type'
      select 'eeg',   from: 'device_law'
      select 'sun',   from: 'device_primary_energy'
      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_manufacturer_product_serialnumber,  with: '12345'
      fill_in :device_watt_peak,                          with: 2000

      click_button 'submit'
      expect(page).to have_content("can't be blank")

      select 'eeg',   from: 'device_law'
      select 'pv',    from: 'device_generator_type'
      select '',      from: 'device_primary_energy'
      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_manufacturer_product_serialnumber,  with: '12345'
      fill_in :device_watt_peak,                          with: 2000

      click_button 'submit'
      expect(page).to have_content("can't be blank")

      select 'eeg',   from: 'device_law'
      select 'pv',    from: 'device_generator_type'
      select 'sun',      from: 'device_primary_energy'
      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_manufacturer_product_serialnumber,  with: '12345'
      fill_in :device_watt_peak,                          with: 2000

      click_button 'submit'
      expect(page).to have_content("Belongs To")
    end
  end
end