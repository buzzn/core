require 'spec_helper'


feature 'Contract' do
  describe 'try to manage_contracts', :js do

    before do
      @user = Fabricate(:christian)
      @user.contracting_party = Fabricate(:contracting_party)
      @metering_point = Fabricate(:mp_60138988)
      @user.add_role(:manager, @metering_point)
      # @electricity_supplier_contract = Fabricate(:electricity_supplier_contract)
      # @metering_point.contracts << @electricity_supplier_contract
      # @user.contracting_party.contracts << @electricity_supplier_contract
      @orgnization1 = Fabricate(:metering_point_operator, name: 'Stadtwerke Augsburg')
      @orgnization2 = Fabricate(:metering_point_operator, name: 'Discovergy')
      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create metering_point_operator_contract without smart meter', :retry => 3 do
      visit "/metering_points/#{@metering_point.id}"
      click_on 'Create contract'

      expect(page).to have_content('New Contract')

      select 'metering_point_operator_contract',                    from: 'contract_mode'
      select 'Stadtwerke Augsburg',                                 from: 'contract_organization_id'
      fill_in :contract_tariff,                                     with: 'blabla'
      fill_in :contract_price_cents,                                with: 8888

      click_button 'submit'
      expect(find('.contract')).to have_content('Stadtwerke Augsburg')
    end

    it 'will fail to create second metering_point_operator_contract', :retry => 3 do
      @metering_point_operator_contract = Fabricate(:metering_point_operator_contract, organization: @orgnization1)
      @metering_point.contracts << @metering_point_operator_contract
      @user.contracting_party.contracts << @metering_point_operator_contract
      visit "/metering_points/#{@metering_point.id}"
      click_on 'Create contract'

      expect(page).to have_content('New Contract')

      select 'metering_point_operator_contract',                    from: 'contract_mode'
      select 'Stadtwerke Augsburg',                                 from: 'contract_organization_id'
      fill_in :contract_tariff,                                     with: 'blabla'
      fill_in :contract_price_cents,                                with: 8888

      click_button 'submit'
      expect(page).to have_content("already exists")
    end

    it 'try to edit metering_point_operator_contract', :retry => 3 do
      @metering_point_operator_contract = Fabricate(:metering_point_operator_contract, organization: @orgnization1)
      @metering_point.contracts << @metering_point_operator_contract
      @user.contracting_party.contracts << @metering_point_operator_contract
      visit "/metering_points/#{@metering_point.id}"
      find(".contract").click

      # expect(page).to have_content('Contract Properties')
      # ******************************* UNCOMMENT THESE 2 LINES WHEN ENABLING CONTRACT/SHOW ******************
      # click_on("Edit")

      expect(page).to have_content('Edit Contract')

      select 'metering_point_operator_contract',                    from: 'contract_mode'
      select 'Stadtwerke Augsburg',                                 from: 'contract_organization_id'
      fill_in :contract_tariff,                                     with: 'blabla'
      fill_in :contract_price_cents,                                with: 7777

      click_button 'Update Contract'
      expect(page).to have_content("blabla")
    end

    # it 'try to create metering_point_operator_contract with smart meter' do #TODO: Enable cassette for discovergy request
    #   visit "/metering_points/#{@metering_point.slug}/#contracts"
    #   click_on 'Add Metering Point Operator Contract'

    #   expect(page).to have_content('New Metering Point Operator Contract')

    #   select2 'Discovergy', from: 'metering_point_operator_contract_organization_id'
    #   fill_in :metering_point_operator_contract_username,           with: 'christian@buzzn.net'
    #   fill_in :metering_point_operator_contract_password,           with: 'Roentgen11smartmeter'

    #   click_button 'submit'

    #   expect(find('.metering_point_operator_contracts')).to have_content('Discovergy')

    #   visit "/metering_points/#{@metering_point.id}/#contracts" #reload to check meter.smart?
    #   VCR.use_cassette('bla') do
    #     worker = MeteringPointValidationWorker.new
    #     worker.perform(@metering_point.id)
    #   end

    #   expect(find('.metering_point_operator_contracts')).to have_content('true')
    # end


  end

end