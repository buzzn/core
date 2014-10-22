require 'spec_helper'


feature 'MeteringPointOperatorContract' do
  describe 'try to manage metering_point_operator_contracts', :js do

    before do
      @user = Fabricate(:user)
      @user.contracting_party = Fabricate(:contracting_party)
      @location = Fabricate(:location)
      @user.add_role :manager, @location
      @metering_point = @location.metering_point
      @user.contracting_party.electricity_supplier_contracts << @metering_point.electricity_supplier_contracts.first
      Fabricate(:metering_point_operator, name: 'Stadtwerke Augsburg')
      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => 'testtest'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create metering_point_operator_contract without smart meter' do
      visit "/metering_points/#{@metering_point.slug}/#tab_contracts"
      puts 'visit'
      click_on 'Add Metering Point Operator Contract'
      puts 'click'

      expect(page).to have_content('Password')
      puts 'modal'


      select2 'Stadtwerke Augsburg',                                from: 'metering_point_operator_contract_organization_id'
      fill_in :metering_point_operator_contract_customer_number,    with: 666
      fill_in :metering_point_operator_contract_contract_number,    with: 8888
      fill_in :metering_point_operator_contract_username,           with: ''
      fill_in :metering_point_operator_contract_password,           with: ''
      puts 'fill'

      click_button 'Create Metering Point Operator Contract'
      puts 'click2'
      expect(find('metering_point_operator_contracts')).to have_content('Stadtwerke Augsburg')
    end


  end

end