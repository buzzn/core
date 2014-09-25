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
      page.should have_content('Signed in successfully.')
    end

    it 'will fail to create location' do
      visit "/profiles/#{@user.profile.slug}"
      click_link 'Create New Location'

      fill_in :location_address_attributes_street_name,   with: 'Urbanstraße'
      fill_in :location_address_attributes_street_number, with: 88
      fill_in :location_address_attributes_zip,           with: 10967
      fill_in :location_address_attributes_city,          with: 'Berlin'

      click_button 'Create Location'
      page.should have_content('Your ')

      #fill_in :location_address_attributes_state, with: 'Berlin'


      # find("Add New Device", match: :first).click

    end


  end

end