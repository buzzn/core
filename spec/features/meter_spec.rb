require 'spec_helper'


feature 'Meter' do
  describe 'try to manage meters', :js do

    before do
      Fabricate(:metering_point_operator, name: 'Discovergy')
      @user = Fabricate(:christian)
      @metering_point = Fabricate(:metering_point)
      @user.add_role :admin

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create meter', :retry => 3  do
      visit "/metering_points/#{@metering_point.id}"

      expect(page).to have_content('Meter')

      click_on 'Create Meter'

      find('.meter_metering_points').find(:css, "input[id^='s2id_autogen']").set("#{@metering_point.name}")
      find(".select2-drop").native.send_keys(:return)
      fill_in :meter_manufacturer_product_serialnumber, with: '123456789'
      find('.meter_metering_points').find(:css, "input[id^='s2id_autogen']").set("#{@metering_point.name}")
      find(".select2-drop").native.send_keys(:return)

      find(".modal-footer").find(".btn").trigger('click')

      expect(find(".meters")).to have_content('123456789')
    end

    it 'try to delete equipment', :retry => 3 do
      @meter = Fabricate(:meter)
      @metering_point.meter = @meter

      visit "/meters/#{@meter.id}"

      expect(page).to have_content('Meter Properties')

      click_on 'Edit'

      click_on 'Destroy'

      visit "/metering_points/#{@metering_point.id}"

      expect(find(".meters")).not_to have_content("#{@meter.name}")
    end

    it 'try to edit equipment', :retry => 3 do
      @meter = Fabricate(:meter)
      @metering_point.meter = @meter

      visit "/meters/#{@meter.id}"

      expect(page).to have_content('Meter Properties')

      click_on 'Edit'

      fill_in :meter_manufacturer_product_serialnumber, with: '1234567890'

      click_on 'Update Meter'

      expect(find("#page-content")).to have_content("1234567890")

    end
  end
end