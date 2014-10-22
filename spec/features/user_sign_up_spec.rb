require 'spec_helper'


feature 'UserSignUpTest' do


  describe 'try_to_sign_up', :js do

    it 'sign_up' do
      visit '/users/sign_up'
      fill_in :user_profile_attributes_first_name,  :with => 'felix'
      fill_in :user_profile_attributes_last_name,   :with => 'faerber'
      fill_in :user_email,                          :with => 'ffaerber@gmail.de'
      fill_in :user_password,                       :with => 'testtest'
      fill_in :user_password_confirmation,          :with => 'testtest'
      click_button 'submit'
      expect(find('.alert')).to have_content('A message with a confirmation link has been sent to your email address. Please open the link to activate your account.')

      ctoken = last_email.body.match('confirmation_token=(.*)"')[1]
      visit "/users/confirmation?confirmation_token=#{ctoken}"
      expect(page).to have_content('Your account was successfully confirmed.')
    end


  end

end