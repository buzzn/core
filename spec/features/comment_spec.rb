require 'spec_helper'


feature 'Comment' do
  describe 'try to manage comments', :js do

    before do
      @user = Fabricate(:justus)
      @fichtenweg8 = Fabricate(:fichtenweg8)

      mp_z1 = Fabricate(:mp_z1)
      mp_z2 = Fabricate(:mp_z2)
      mp_z3 = Fabricate(:mp_z3)
      mp_z4 = Fabricate(:mp_z4)
      mp_z5 = Fabricate(:mp_z5)

      mp_z2.update_attribute :parent, mp_z1
      mp_z3.update_attribute :parent, mp_z1
      mp_z4.update_attribute :parent, mp_z1
      mp_z5.update_attribute :parent, mp_z1

      @fichtenweg8.metering_point = mp_z1

      @device        = Fabricate(:dach_pv_justus)
      @user.add_role :manager, @device
      @user.add_role :manager, @fichtenweg8

      @group_home_of_the_brave = Fabricate(:group_home_of_the_brave, metering_points: [@fichtenweg8.metering_point], assets: [])
      @user.add_role :manager, @group_home_of_the_brave

      @user2 = Fabricate(:user)
      @location = Fabricate(:location)
      @location.metering_point.group = @group_home_of_the_brave
      @user3 = Fabricate(:user)

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create and remove comment', :retry => 3 do
      visit "/groups/#{@group_home_of_the_brave.slug}"
      click_on 'Comments'

      fill_in 'comment_body', with: 'Test Comment'

      click_button 'Create Comment'

      expect(find(".comment")).to have_content('Test Comment')

      find(".comment").find(".close").click

      expect(page.has_css?(".comment", visible: false))
    end

    it 'will fail to create comment', :retry => 3 do
      visit "/groups/#{@group_home_of_the_brave.slug}"
      click_on 'Comments'

      click_button 'Create Comment'

      expect(find(".comments-all")).not_to have_selector('comment')
    end

    it 'will not be allowed to remove comment', :retry => 3 do
      visit "/groups/#{@group_home_of_the_brave.slug}"
      click_on 'Comments'

      fill_in 'comment_body', with: 'Test Comment'

      click_button 'Create Comment'

      expect(find(".comments-all")).to have_content('Test Comment')

      visit "/profiles/#{@user2.profile.slug}"  #nessessary to enable matching to .nav
      find(".nav").click_link "#{@user2.name}"
      click_on 'Logout'
      visit '/users/sign_in'
      fill_in :user_email,    :with => @user3.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      visit "/groups/#{@group_home_of_the_brave.slug}"
      click_on 'Comments'

      expect(find(".comments-all")).to have_content('Test Comment')

      expect(find(".comments-all")).not_to have_selector('.close')
    end

    it 'will not be allowed to create comment', :retry => 3 do
      find(".nav").click_link "#{@user2.name}"
      click_on 'Logout'
      visit "/groups/#{@group_home_of_the_brave.slug}#tab_comments"

      expect(find(".comments")).not_to have_selector(".comment-form")
    end
  end
end