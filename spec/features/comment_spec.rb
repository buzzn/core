require 'spec_helper'


feature 'Comment' do
  describe 'try to manage comments', :js do

    before do
      @user = Fabricate(:user)
      @metering_point = Fabricate(:mp_pv_karin)
      @user.add_role(:manager, @metering_point)

      @group = Fabricate(:group, metering_points: [@metering_point])
      @user.add_role(:manager, @group)

      @user2 = Fabricate(:user)
      @metering_point2 = Fabricate(:mp_60009269)
      @user2.add_role(:manager, @metering_point2)
      @group.metering_points << @metering_point2

      @user3 = Fabricate(:user)

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create and remove comment', :retry => 3 do
      visit "/groups/#{@group.slug}"

      fill_in 'comment_body', with: 'Test Comment'

      click_button 'Create comment'

      expect(find(".comment")).to have_content('Test Comment')

      find(".comment").find(".close").click

      expect(page.has_css?(".comment", visible: false))
    end

    it 'will fail to create comment', :retry => 3 do
      visit "/groups/#{@group.slug}"

      click_button 'Create comment'

      expect(find(".comments-all")).not_to have_selector('comment')
    end

    it 'will not be allowed to remove comment', :retry => 3 do
      visit "/groups/#{@group.slug}"

      fill_in 'comment_body', with: 'Test Comment'

      click_button 'Create comment'

      expect(find(".comments-all")).to have_content('Test Comment')

      find(".navbar-content").click_link "#{@user2.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user3.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
      expect(page).to have_content('Signed in successfully.')

      visit "/groups/#{@group.slug}"

      expect(find(".comments-all")).to have_content('Test Comment')

      expect(find(".comments-all")).not_to have_selector('.close')
    end

    it 'will not be allowed to create comment', :retry => 3 do
      find(".navbar-content").click_link "#{@user2.name}"
      click_on 'Logout'

      visit "/groups/#{@group.slug}#comments"

      expect(find(".comments-all")).not_to have_selector(".new_comment")
    end
  end
end