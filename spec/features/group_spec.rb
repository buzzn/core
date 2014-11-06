require 'spec_helper'


feature 'Group' do
  describe 'try to manage groups', :js do

    before do
      Fabricate(:metering_point_operator, name: 'Discovergy')
      @user = Fabricate(:karin)
      @location = Fabricate(:gautinger_weg)
      @location.metering_point.users << @user
      @user.add_role :manager, @location
      @pv_karin = Fabricate(:pv_karin)
      @user.add_role :manager, @pv_karin
      @location.metering_point.devices << @pv_karin
      @location.metering_point.electricity_supplier_contracts.first.contracting_party = @user.contracting_party
      @location.metering_point.electricity_supplier_contracts.first.save

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create group', :retry => 3 do
      visit "/profiles/#{@user.profile.slug}"
      click_on 'Groups'
      expect(page).to have_content('Add New Group')
      click_on 'Add New Group'
      expect(page).to have_content('Description')

      select2 "#{@location.metering_point.decorate.name}", from: 'group_metering_point_ids'
      fill_in :group_name,            with: 'Testgruppe'
      fill_in :group_description,     with: 'So eine tolle Testgruppe haben wir hier.'

      click_button 'submit'
      expect(page).to have_content('Assets')

      click_on 'Members'
      expect(page).to have_content('Energy Producers')

      click_on 'Assets'

      click_on 'Contracts'
      expect(page).to have_content('Add Metering Point Operator Contract')

      click_on 'Comments'
      fill_in :comment_body,          with: 'Testcomment?!'
      click_on 'Create Comment'
      expect(find(".comment")).to have_content('Testcomment?!')
    end

    it 'will fail to create group', :retry => 3 do
      visit "/profiles/#{@user.profile.slug}"
      click_on 'Groups'
      expect(page).to have_content('Add New Group')
      click_on 'Add New Group'
      expect(page).to have_content('Description')

      fill_in :group_name,            with: 'Testgruppe'
      fill_in :group_description,     with: 'Das sollte niemals zu sehen sein.'

      click_button 'submit'
      expect(page).to have_content("can't be blank")

      select2 "#{@location.metering_point.decorate.name}", from: 'group_metering_point_ids'
      fill_in :group_name,            with: ''
      fill_in :group_description,     with: 'Das sollte niemals zu sehen sein.'

      click_button 'submit'
      expect(page).to have_content("can't be blank")

      fill_in :group_description,     with: 'So eine tolle Testgruppe haben wir hier.'
      fill_in :group_name,            with: 'Testgruppe'

      click_button 'submit'
      expect(page).to have_content('Assets')
    end

    it 'will not be allowed to create group', :retry => 3 do
      @user2 = Fabricate(:user)
      @location2 = Fabricate(:location)

      find(".nav").click_link "#{@user.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'

      expect(find(".nav")).not_to have_link "Groups"
    end

    it 'will not be allowed to edit group', :retry => 3 do
      @user2 = Fabricate(:user)
      @location2 = Fabricate(:location)
      @group = Fabricate(:group, metering_points: [ @location2.metering_point ])
      @user2.add_role :manager, @group
      @group.metering_points << @location.metering_point

      visit "/groups/#{@group.slug}"

      expect(page).not_to have_link('Edit', :href => edit_group_path(@group))
    end
  end
end