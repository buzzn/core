require 'spec_helper'


feature 'Asset' do
  describe 'try to manage assets', :js do

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

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create asset (device)' do
      visit "/devices/#{@device.id}"
      expect(page).to have_content('solarwatt')
      find("i.fa-plus-circle").click

      attach_file :asset_image,           Rails.root.join('db', 'seed_assets', 'assets', 'pv_karin.jpg')
      fill_in :asset_description,         with: 'Tolles Bild'

      click_on 'Create Asset'
      expect(find(".caption")).to have_content('Tolles Bild')
    end

    it 'will fail to create asset (device)' do
      visit "/devices/#{@device.id}"
      expect(page).to have_content('solarwatt')
      find("i.fa-plus-circle").click

      fill_in :asset_description,         with: 'Tolles Bild'

      click_on 'Create Asset'
      expect(page).not_to have_content('Show')

      attach_file :asset_image,           Rails.root.join('db', 'seed_assets', 'assets', 'pv_karin.jpg')
      fill_in :asset_description,         with: 'Tolles Bild'

      click_on 'Create Asset'
      expect(find(".caption")).to have_content('Tolles Bild')
    end

    it 'try to create asset (group)' do
      visit "/groups/#{@group_home_of_the_brave.slug}"
      expect(page).to have_content('Assets')
      click_on 'Assets'
      find("i.fa-plus-circle").click

      attach_file :asset_image,           Rails.root.join('db', 'seed_assets', 'assets', 'pv_karin.jpg')
      fill_in :asset_description,         with: 'Tolles Bild'

      click_on 'Create Asset'
      expect(find(".caption")).to have_content('Tolles Bild')
    end

    it 'will fail to create asset (group)' do
      visit "/groups/#{@group_home_of_the_brave.slug}"
      expect(page).to have_content('Assets')
      click_on 'Assets'
      find("i.fa-plus-circle").click

      fill_in :asset_description,         with: 'Tolles Bild'

      click_on 'Create Asset'
      expect(page).not_to have_content('Show')

      attach_file :asset_image,           Rails.root.join('db', 'seed_assets', 'assets', 'pv_karin.jpg')
      fill_in :asset_description,         with: 'Tolles Bild'

      click_on 'Create Asset'
      expect(find(".caption")).to have_content('Tolles Bild')
    end


  end

end