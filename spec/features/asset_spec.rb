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

    it 'try to create asset (device)', :retry => 3 do
      visit "/devices/#{@device.id}"
      expect(page).to have_content('solarwatt')
      click_on 'Assets'
      find("i.fa-plus-circle").click

      attach_file :asset_image,           Rails.root.join('db', 'seed_assets', 'assets', 'pv_karin.jpg')
      fill_in :asset_description,         with: 'Tolles Bild'

      click_on 'Create Asset'
      expect(find(".caption")).to have_content('Tolles Bild')
    end

    it 'will fail to create asset (device)', :retry => 3 do
      visit "/devices/#{@device.id}"
      expect(page).to have_content('solarwatt')
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

    it 'try to edit asset (device)', :retry => 3 do
      @device.assets << Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'ecopower1.jpg')), description: 'ecopower')

      visit "/devices/#{@device.id}"
      expect(page).to have_content('solarwatt')
      click_on 'Assets'
      find(".assets").find(".thumbnail").click_on('Edit')

      fill_in 'asset_description', with: 'Nice picture'

      click_on 'Update Asset'

      expect(find(".assets").find(".thumbnail")).to have_content('Nice picture')
    end

    it 'will not be allowed to edit asset (device)', :retry => 3 do
      @device.assets << Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'ecopower1.jpg')), description: 'ecopower')
      @user2 = Fabricate(:user)
      @user.friends << @user2

      find(".nav").click_link "#{@user.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'

      visit "/devices/#{@device.id}"
      expect(page).to have_content('solarwatt')
      click_on 'Assets'
      expect(find(".assets").find(".thumbnail")).not_to have_content('Edit')

      click_on 'Show'

      expect(find(".modal-body")).to have_content('ecopower')
    end

    it 'try to create asset (group)', :retry => 3 do
      visit "/groups/#{@group_home_of_the_brave.slug}"
      expect(page).to have_content('Assets')
      click_on 'Assets'
      find("i.fa-plus-circle").click

      attach_file :asset_image,           Rails.root.join('db', 'seed_assets', 'assets', 'pv_karin.jpg')
      fill_in :asset_description,         with: 'Tolles Bild'

      click_on 'Create Asset'
      expect(find(".caption")).to have_content('Tolles Bild')
    end

    it 'will fail to create asset (group)', :retry => 3 do
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

    it 'try to edit asset (group)', :retry => 3 do
      @group_home_of_the_brave.assets << Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'ecopower1.jpg')), description: 'ecopower')

      visit "/groups/#{@group_home_of_the_brave.slug}#assets"
      expect(page).to have_content('ecopower')
      find(".assets").find(".thumbnail").click_on('Edit')

      fill_in 'asset_description', with: 'Nice picture'

      click_on 'Update Asset'

      expect(find(".assets").find(".thumbnail")).to have_content('Nice picture')
    end

    it 'will not be allowed to edit asset (group)', :retry => 3 do
      @group_home_of_the_brave.assets << Fabricate( :asset, image: File.new(Rails.root.join('db', 'seed_assets', 'assets', 'ecopower1.jpg')), description: 'ecopower')
      @user2 = Fabricate(:user)

      find(".nav").click_link "#{@user.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'

      visit "/groups/#{@group_home_of_the_brave.slug}#assets"
      expect(page).to have_content('ecopower')
      expect(find(".assets").find(".thumbnail")).not_to have_content('Edit')

      click_on 'Show'

      expect(find(".modal-body")).to have_content('ecopower')

      @location2 = Fabricate(:location)
      @user2.add_role :manager, @location2
      @group_home_of_the_brave.metering_points << @location2.metering_point

      visit "/profiles/#{@user2.profile.slug}"
      find(".nav").click_link "#{@user2.name}"
      click_on 'Logout'

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user2.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'

      visit "/groups/#{@group_home_of_the_brave.slug}#assets"
      expect(page).to have_content('ecopower')
      expect(find(".assets").find(".thumbnail")).not_to have_content('Edit')

      click_on 'Show'

      expect(find(".modal-body")).to have_content('ecopower')
    end
  end

end