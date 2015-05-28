require 'spec_helper'


feature 'Device' do
  describe 'try to manage devices', :js do

    before do
      @user = Fabricate(:user)
      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create device', :retry => 3  do
      visit "/profiles/#{@user.profile.slug}"
      click_on 'Create Device'

      select :in,                                         from: 'device_mode'
      fill_in :device_category,                           with: 'Testkategorie'
      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_watt_peak,                          with: 200

      click_button 'submit'

      expect(find(".devices")).to have_content('Testgerät')
    end

    it 'will fail to create device', :retry => 3  do
      visit "/profiles/#{@user.profile.slug}"
      click_on 'Create Device'

      select :in,                                         from: 'device_mode'
      fill_in :device_category,                           with: 'Testkategorie'
      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'

      click_button 'submit'
      expect(page).to have_content("is not a number")

      select :in,                                         from: 'device_mode'
      fill_in :device_category,                           with: 'Testkategorie'
      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_watt_peak,                          with: "abc"

      click_button 'submit'
      expect(page).to have_content("is not a number")

      select :in,                                         from: 'device_mode'
      fill_in :device_category,                           with: 'Testkategorie'
      fill_in :device_manufacturer_name,                  with: 'Testgerät'
      fill_in :device_manufacturer_product_name,          with: ''
      fill_in :device_watt_peak,                          with: 200

      click_button 'submit'
      expect(page).to have_content("can't be blank")

      select :in,                                         from: 'device_mode'
      fill_in :device_category,                           with: 'Testkategorie'
      fill_in :device_manufacturer_name,                  with: ''
      fill_in :device_manufacturer_product_name,          with: 'Testname'
      fill_in :device_watt_peak,                          with: 200

      click_button 'submit'
      expect(page).to have_content("can't be blank")
    end

    # it 'try to create out device', :retry => 1  do     # *********There is no diference between out- & in-device at the moment************
    #   visit "/profiles/#{@user.profile.slug}"
    #   click_on 'Create Device'

    #   select 'eeg',   from: 'device_law'
    #   select 'sun',   from: 'device_primary_energy'
    #   fill_in :device_category,                        with: 'pv'
    #   fill_in :device_manufacturer_name,                  with: 'Testgerät'
    #   fill_in :device_manufacturer_product_name,          with: 'Testname'
    #   fill_in :device_manufacturer_product_serialnumber,  with: '12345'
    #   fill_in :device_watt_peak,                          with: 2000

    #   click_button 'submit'
    #   expect(page).to have_content('Belongs To')
    # end

    # it 'will fail to create out device', :retry => 3 do
    #   visit "/profiles/#{@user.profile.slug}"
    #   click_on 'Devices'
    #   expect(page).to have_content('Add New Out Device')
    #   click_on 'Add New Out Device'
    #   expect(page).to have_content('Manufacturer')

    #   select '',      from: 'device_law'
    #   select 'sun',   from: 'device_primary_energy'
    #   fill_in :device_category,                        with: 'pv'
    #   fill_in :device_manufacturer_name,                  with: 'Testgerät'
    #   fill_in :device_manufacturer_product_name,          with: 'Testname'
    #   fill_in :device_manufacturer_product_serialnumber,  with: '12345'
    #   fill_in :device_watt_peak,                          with: 2000

    #   click_button 'submit'
    #   expect(page).to have_content("can't be blank")

    #   select 'eeg',   from: 'device_law'
    #   select 'sun',   from: 'device_primary_energy'
    #   fill_in :device_category,                        with: ''
    #   fill_in :device_manufacturer_name,                  with: 'Testgerät'
    #   fill_in :device_manufacturer_product_name,          with: 'Testname'
    #   fill_in :device_manufacturer_product_serialnumber,  with: '12345'
    #   fill_in :device_watt_peak,                          with: 2000

    #   click_button 'submit'
    #   expect(page).to have_content("can't be blank")

    #   select 'eeg',   from: 'device_law'
    #   select '',      from: 'device_primary_energy'
    #   fill_in :device_category,                        with: 'pv'
    #   fill_in :device_manufacturer_name,                  with: 'Testgerät'
    #   fill_in :device_manufacturer_product_name,          with: 'Testname'
    #   fill_in :device_manufacturer_product_serialnumber,  with: '12345'
    #   fill_in :device_watt_peak,                          with: 2000

    #   click_button 'submit'
    #   expect(page).to have_content("can't be blank")

    #   select 'eeg',   from: 'device_law'
    #   select 'sun',      from: 'device_primary_energy'
    #   fill_in :device_category,                        with: 'pv'
    #   fill_in :device_manufacturer_name,                  with: 'Testgerät'
    #   fill_in :device_manufacturer_product_name,          with: 'Testname'
    #   fill_in :device_manufacturer_product_serialnumber,  with: '12345'
    #   fill_in :device_watt_peak,                          with: 2000

    #   click_button 'submit'
    #   expect(page).to have_content("Belongs To")
    # end

    it 'try to edit device', :retry => 3 do
      @device = Fabricate(:dach_pv_justus)
      @user.add_role(:manager, @device)

      visit "/devices/#{@device.id}"

      click_on 'Edit'

      fill_in :device_manufacturer_name,                  with: 'Testgerät2'

      click_on 'Update Device'

      expect(find("#page-content")).to have_content('Testgerät2')
    end

    it 'will not be allowed to edit device', :retry => 3 do
      @user2 = Fabricate(:user)
      @device = Fabricate(:dach_pv_justus)
      @user2.add_role :manager, @device
      @user.friends << @user2

      visit "/devices/#{@device.id}"

      expect(page).to have_content('solarwatt')

      expect(page).not_to have_link('Edit', :href => edit_device_path(@device))
    end

    it 'will not be allowed to view device', :retry => 3 do
      @user2 = Fabricate(:user)
      @device = Fabricate(:dach_pv_justus)
      @user2.add_role :manager, @device

      visit "/profiles/#{@user2.profile.slug}"

      expect(page).not_to have_selector(".devices")

      visit "/devices/#{@device.id}"

      expect(page).to have_content('Access Denied')

      @user2.friends << @user

      visit "/profiles/#{@user2.profile.slug}"

      expect(page).to have_selector(".devices")

      visit "/devices/#{@device.id}"

      expect(page).not_to have_content('Access Denied')
    end
  end
end