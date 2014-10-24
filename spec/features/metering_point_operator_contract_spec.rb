require 'spec_helper'


feature 'MeteringPointOperatorContract' do
  describe 'try to manage metering_point_operator_contracts', :js do

    before do
      @user = Fabricate(:christian)
      @user.contracting_party = Fabricate(:contracting_party)
      @location = Fabricate(:roentgenstrasse11)
      @user.add_role :manager, @location
      @metering_point = @location.metering_point
      @user.contracting_party.electricity_supplier_contracts << @metering_point.electricity_supplier_contracts.first
      Fabricate(:metering_point_operator, name: 'Stadtwerke Augsburg')
      Fabricate(:metering_point_operator, name: 'Discovergy')
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
      click_on 'Add Metering Point Operator Contract'

      expect(page).to have_content('New Metering Point Operator Contract')

      select2 'Stadtwerke Augsburg', from: 'metering_point_operator_contract_organization_id'
      fill_in :metering_point_operator_contract_customer_number,    with: 666
      fill_in :metering_point_operator_contract_contract_number,    with: 8888
      fill_in :metering_point_operator_contract_username,           with: ''
      fill_in :metering_point_operator_contract_password,           with: ''

      click_button 'submit'
      expect(find('.metering_point_operator_contracts')).to have_content('Stadtwerke Augsburg')
    end

    it 'will fail to create metering_point_operator_contract without smart meter' do
      visit "/metering_points/#{@metering_point.slug}/#tab_contracts"
      click_on 'Add Metering Point Operator Contract'

      expect(page).to have_content('New Metering Point Operator Contract')

      fill_in :metering_point_operator_contract_customer_number,    with: 666
      fill_in :metering_point_operator_contract_contract_number,    with: 8888
      fill_in :metering_point_operator_contract_username,           with: ''
      fill_in :metering_point_operator_contract_password,           with: ''

      click_button 'submit'
      expect(page).to have_content("can't be blank")
    end

    # it 'try to create metering_point_operator_contract with smart meter' do
    #   visit "/metering_points/#{@metering_point.slug}/#tab_contracts"
    #   click_on 'Add Metering Point Operator Contract'

    #   expect(page).to have_content('New Metering Point Operator Contract')

    #   select2 'Discovergy', from: 'metering_point_operator_contract_organization_id'
    #   fill_in :metering_point_operator_contract_username,           with: 'christian@buzzn.net'
    #   fill_in :metering_point_operator_contract_password,           with: 'Roentgen11smartmeter'

    #   click_button 'submit'

    #   expect(find('.metering_point_operator_contracts')).to have_content('Discovergy')

    #   visit "/metering_points/#{@metering_point.slug}/#tab_contracts" #reload to check meter.smart?
    #   VCR.use_cassette('bla') do
    #     worker = MeteringPointValidationWorker.new
    #     worker.perform(@metering_point.id)
    #   end

    #   expect(find('.metering_point_operator_contracts')).to have_content('true')
    # end

    it 'will fail to create metering_point_operator_contract with smart meter' do
      visit "/metering_points/#{@metering_point.slug}/#tab_contracts"
      click_on 'Add Metering Point Operator Contract'

      expect(page).to have_content('New Metering Point Operator Contract')

      select2 'Discovergy', from: 'metering_point_operator_contract_organization_id'
      fill_in :metering_point_operator_contract_customer_number,    with: 666
      fill_in :metering_point_operator_contract_contract_number,    with: 8888
      fill_in :metering_point_operator_contract_username,           with: ''
      fill_in :metering_point_operator_contract_password,           with: 'test'

      click_button 'submit'
      expect(page).to have_content("can't be blank")

      select2 'Discovergy', from: 'metering_point_operator_contract_organization_id'
      fill_in :metering_point_operator_contract_customer_number,    with: 666
      fill_in :metering_point_operator_contract_contract_number,    with: 8888
      fill_in :metering_point_operator_contract_username,           with: 'test@test.de'
      fill_in :metering_point_operator_contract_password,           with: ''

      click_button 'submit'
      expect(page).to have_content("can't be blank")
    end




  end

end