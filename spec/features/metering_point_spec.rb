require 'spec_helper'


feature 'MeteringPoint' do
  describe 'try to manage metering_points', :js do

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

    it 'try to create metering_point', :retry => 3 do
      #find("#registers").all(".nested-fields").last.find(:css, "input[id^='meter_registers_attributes_'][id$='_obis_index']").set("12345678")
      #find("#registers").all(".nested-fields").last.find(:css, "select[id^='meter_registers_attributes_'][id$='_mode']").find(:xpath, 'option[2]').select_option

      click_on 'Create Metering Point'

      fill_in :metering_point_name,       with: 'Wohnung'
      #fill_in :metering_point_uid,        with: 'DE123456789012345678901'
      #select  :world,                     from: 'metering_point_readable'
      page.choose('metering_point_mode_in')

      click_button 'Continue'

      fill_in :meter_manufacturer_product_serialnumber, with: 12345678
      page.choose('meter_smartmeter_nein')

      click_button 'Continue'

      expect(page).to have_content('Loading...')

      find(".metering_point").click

      expect(page).to have_content('Address')
    end

    it 'will fail to create metering_point', :retry => 3 do
      click_on 'Create Metering Point'

      fill_in :metering_point_name,       with: 'Wohnung'
      #fill_in :metering_point_uid,        with: 'DE123456789012345678901'
      #select  :world,                     from: 'metering_point_readable'

      click_button 'Continue'
      expect(page).to have_content("can't be blank")

      fill_in :metering_point_name,       with: ''
      page.choose('metering_point_mode_in')
      #fill_in :metering_point_uid,        with: 'DE12345678901234567890123456789012345'
      #select  :world,                     from: 'metering_point_readable'

      click_button 'Continue'
      expect(page).to have_content("can't be blank")

      fill_in :metering_point_name,       with: 'Wohnung'
      page.choose('metering_point_mode_in')
      #fill_in :metering_point_uid,        with: 'DE123456789012345678901'
      #select  :world,                     from: 'metering_point_readable'

      click_button 'Continue'

      fill_in :meter_manufacturer_product_serialnumber, with: 12345678
      page.choose('meter_smartmeter_nein')

      click_button 'Continue'
      expect(page).to have_content('Loading...')
    end

    it 'will not be allowed to view metering_point as friend', :retry => 3 do
      @user2 = Fabricate(:user)
      @metering_point2 = Fabricate(:mp_60009269, readable: "me")
      @user2.add_role(:manager, @metering_point2)
      @user.friends << @user2
      @user.save

      visit "/profiles/#{@user.profile.slug}"

      expect(page).to have_content("#{@user2.name}")

      visit "/metering_points/#{@user2.editable_metering_points.first.id}"

      expect(page).to have_content "Access Denied"
    end

    it 'will be allowed to view metering_point as friend', :retry => 3 do
      @user2 = Fabricate(:user)
      @metering_point2 = Fabricate(:mp_60009269, readable: "friends")
      @user2.add_role(:manager, @metering_point2)
      @user.friends << @user2
      @user.save

      visit "/profiles/#{@user.profile.slug}"

      expect(page).to have_content("#{@user2.name}")

      visit "/metering_points/#{@user2.editable_metering_points.first.id}"

      expect(page).not_to have_content "Access Denied"
    end

    it 'will be allowed to view metering_point as world', :retry => 3 do
      @user2 = Fabricate(:user)
      @metering_point2 = Fabricate(:mp_60009269, readable: "world")
      @user2.add_role(:manager, @metering_point2)

      visit "/profiles/#{@user.profile.slug}"

      expect(page).not_to have_content("#{@user2.name}")

      visit "/metering_points/#{@user2.editable_metering_points.first.id}"

      expect(page).not_to have_content "Access Denied"
    end

  end

end