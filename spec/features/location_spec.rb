require 'spec_helper'


feature 'Location' do
  describe 'try to manage locations', :js do

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

    it 'try to create location', :retry => 3 do
      visit "/profiles/#{@user.profile.slug}"
      click_link 'Create New Location'

      fill_in :location_address_attributes_street_name,   with: 'Urbanstraße'
      fill_in :location_address_attributes_street_number, with: 88
      fill_in :location_address_attributes_zip,           with: 10967
      fill_in :location_address_attributes_city,          with: 'Berlin'
      fill_in :location_address_attributes_state,         with: 'Berlin'
      select  'Berlin',                                   from: 'location_address_attributes_time_zone'

      click_button 'Create Location'
      expect(page).to have_content('location_created_successfully')
    end

    it 'will fail to create location', :retry => 3 do
      visit "/profiles/#{@user.profile.slug}"
      click_link 'Create New Location'

      fill_in :location_address_attributes_street_name,   with: 'Urbanstraße'
      fill_in :location_address_attributes_street_number, with: 88
      fill_in :location_address_attributes_zip,           with: 10967
      fill_in :location_address_attributes_city,          with: 'Berlin'
      fill_in :location_address_attributes_state,         with: 'Berlin'

      click_button 'Create Location'
      expect(page).to have_content("is not included in the list")

      fill_in :location_address_attributes_street_name,   with: ''
      fill_in :location_address_attributes_street_number, with: 88
      fill_in :location_address_attributes_zip,           with: 10967
      fill_in :location_address_attributes_city,          with: 'Berlin'
      fill_in :location_address_attributes_state,         with: 'Berlin'
      select  'Berlin',                                   from: 'location_address_attributes_time_zone'

      click_button 'Create Location'
      expect(page).to have_content("can't be blank")

      fill_in :location_address_attributes_street_name,   with: 'Urbanstraße'
      fill_in :location_address_attributes_street_number, with: ''
      fill_in :location_address_attributes_zip,           with: 10967
      fill_in :location_address_attributes_city,          with: 'Berlin'
      fill_in :location_address_attributes_state,         with: 'Berlin'
      select  'Berlin',                                   from: 'location_address_attributes_time_zone'

      click_button 'Create Location'
      expect(page).to have_content("can't be blank")

      fill_in :location_address_attributes_street_name,   with: 'Urbanstraße'
      fill_in :location_address_attributes_street_number, with: 88
      fill_in :location_address_attributes_zip,           with: ''
      fill_in :location_address_attributes_city,          with: 'Berlin'
      fill_in :location_address_attributes_state,         with: 'Berlin'
      select  'Berlin',                                   from: 'location_address_attributes_time_zone'

      click_button 'Create Location'
      expect(page).to have_content("can't be blank")

      fill_in :location_address_attributes_street_name,   with: 'Urbanstraße'
      fill_in :location_address_attributes_street_number, with: 88
      fill_in :location_address_attributes_zip,           with: 10967
      fill_in :location_address_attributes_city,          with: ''
      fill_in :location_address_attributes_state,         with: 'Berlin'
      select  'Berlin',                                   from: 'location_address_attributes_time_zone'

      click_button 'Create Location'
      expect(page).to have_content("can't be blank")

      fill_in :location_address_attributes_street_name,   with: 'Urbanstraße'
      fill_in :location_address_attributes_street_number, with: 88
      fill_in :location_address_attributes_zip,           with: 10967
      fill_in :location_address_attributes_city,          with: 'Berlin'
      fill_in :location_address_attributes_state,         with: ''
      select  'Berlin',                                   from: 'location_address_attributes_time_zone'

      click_button 'Create Location'
      expect(page).to have_content("can't be blank")

      fill_in :location_address_attributes_street_name,   with: 'Urbanstraße'
      fill_in :location_address_attributes_street_number, with: 88
      fill_in :location_address_attributes_zip,           with: 10967
      fill_in :location_address_attributes_city,          with: 'Berlin'
      fill_in :location_address_attributes_state,         with: 'Berlin'
      select  'Berlin',                                   from: 'location_address_attributes_time_zone'

      click_button 'Create Location'
      expect(page).to have_content('location_created_successfully')
    end

    it 'will try to delete location', :retry => 3  do
      @location = Fabricate(:location)
      @user.add_role :manager, @location

      visit "/profiles/#{@user.profile.slug}"

      find(".nav").click_link("Locations")
      click_on "#{@location.long_name}"

      expect(page).to have_content("#{@location.metering_point.decorate.name}")

      find("i.fa.fa-cog").click

      expect(page).to have_content("Edit Location")

      find(".modal-footer").find("a.btn.btn-danger").click

      expect(page).to have_content("You Have No Location")
    end
  end
end