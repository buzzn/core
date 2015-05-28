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
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create friendship', :retry => 3 do
      visit "/profiles/#{@user2.profile.slug}"
      click_on 'Friend Request'

      expect(page).to have_content('Sent Friendship Request')

      find(".navbar-content").click_link "#{@user1.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      expect(page).to have_content('New Friendship Request')

      find(".bs-callout").click_on "Accept"
      expect(page).to have_content('Accepted Friendship Request')

      visit "/profiles/#{@user2.profile.slug}"

      expect(find(".profiles")).to have_content("#{@user1.name}")
    end

    it 'will fail to create friendship', :retry => 3 do
      visit "/profiles/#{@user2.profile.slug}"
      click_on 'Friend Request'

      expect(page).to have_content('Sent Friendship Request')

      find(".navbar-content").click_link "#{@user1.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      expect(page).to have_content('New Friendship Request')

      find(".bs-callout").click_on "Reject"
      expect(page).to have_content('Rejected Friendship Request')

      visit "/profiles/#{@user2.profile.slug}"

      expect(page).not_to have_content("#{@user1.name}")
    end

    it 'try to cancel friendship', :retry => 3 do
      visit "/profiles/#{@user3.profile.slug}"
      click_on 'Cancel Friendship'

      find(".navbar-content").click_link "#{@user1.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user3.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')
      expect(page).not_to have_content("#{@user1.name}")
    end
  end
end