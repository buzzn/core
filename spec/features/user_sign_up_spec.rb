require 'spec_helper'


feature 'UserSignUpTest' do

  # before(:each) do
  #   load "#{Rails.root}/db/seeds.rb"
  # end

  describe 'try_to_sign_up', :js do

    it 'visit /users/sign_up' do
      visit '/users/sign_up'
      fill_in :user_email,                  :with => 'user_sign_up@test.de'
      fill_in :user_password,               :with => 'testtest'
      fill_in :user_password_confirmation,  :with => 'testtest'

      click_button 'submit'

      find('.alert').should have_content('Erfolgreich angemeldet.')
    end


  end

end