require 'spec_helper'


feature 'Friendship' do
  describe 'try to manage friendships', :js do

    before do
      @user1 = Fabricate(:user)
      @user2 = Fabricate(:user)
      @user3 = Fabricate(:user)
      @user3.friends << @user1

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user1.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create friendship' do
      visit "/profiles/#{@user2.profile.slug}"
      click_on 'Friendship'
      click_on 'Send Friend Request'

      expect(page).to have_content('Sent Friendship Request')

      find(".nav").click_link "#{@user1.name}"
      click_on 'Logout'
      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      expect(page).to have_content('New Friendship Request')

      find(".bs-callout").click_on "Accept"
      expect(page).to have_content('Accepted Friendship Request')
    end

    it 'will fail to create friendship' do
      visit "/profiles/#{@user2.profile.slug}"
      click_on 'Friendship'
      click_on 'Send Friend Request'

      expect(page).to have_content('Sent Friendship Request')

      find(".nav").click_link "#{@user1.name}"
      click_on 'Logout'
      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      expect(page).to have_content('New Friendship Request')

      find(".bs-callout").click_on "Reject"
      expect(page).to have_content('Rejected Friendship Request')
    end

    it 'try to cancel friendship' do
      visit "/profiles/#{@user3.profile.slug}"
      click_on 'Friendship'
      visit '/friendships/3/cancel' #click doesn't work here due to confirmation

      find(".nav").click_link "#{@user1.name}"
      click_on 'Logout'
      visit '/users/sign_in'
      fill_in :user_email,    :with => @user3.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')
      if @user3.friend?(@user1)
        expect(page).to have_content('Niemals sichtbar')
      end
    end
  end
end