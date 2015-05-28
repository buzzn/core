require 'spec_helper'


feature 'FormulaPart' do
  describe 'try to manage fomula_parts', :js => true do

    before do
      @user = Fabricate(:christian)
      @metering_point = Fabricate(:mp_stefans_bhkw)
      @meter = Fabricate(:meter, smart: true, online: true, init_reading: true)
      @metering_point.meter = @meter
      @metering_point.save
      @user.add_role :manager, @metering_point

      @metering_point2 = Fabricate(:mp_pv_karin)
      @meter = Fabricate(:meter, smart: true, online: true, init_reading: true)
      @metering_point2.meter = @meter
      @metering_point2.save
      @user.add_role :manager, @metering_point2

      visit '/users/sign_in'
      fill_in :user_email,    :with => @user.email
      fill_in :user_password, :with => '12345678'
      click_button 'Sign in'
    end

    it 'will be signed in' do
      expect(page).to have_content('Signed in successfully.')
    end

    it 'try to create virtual metering_point', :retry => 3 do
      click_on "Create Metering Point"

      find(".modal-body").find("#metering_point_mode_out").trigger('click')
      find(".modal-body").find("#metering_point_virtual").trigger('click')
      fill_in :metering_point_name,       with: 'Gesamtstrom'
      select  :world,                     from: 'metering_point_readable'
      find("#formula_parts").all(".nested-fields").first.find(:css, "select[id^='metering_point_formula_parts_attributes_'][id$='_operand_id']").select("#{@metering_point.name}")
      find("#formula_parts").all(".nested-fields").last.find(:css, "select[id^='metering_point_formula_parts_attributes_'][id$='_operand_id']").select("#{@metering_point2.name}")

      click_on 'submit'

      click_on 'Without Address'

      expect(find("#mainnav-menu")).to have_content("Gesamtstrom")
    end

    it 'try to add formula_part to metering_point', :retry => 3 do
      @metering_point3 = Fabricate(:mp_hof_butenland_wind)
      @meter = Fabricate(:meter, smart: true, online: true, init_reading: true)
      @metering_point3.meter = @meter
      @metering_point3.save
      @user.add_role :manager, @metering_point3

      @metering_point4 = Fabricate(:metering_point, virtual: true)
      @metering_point4.formula_parts << Fabricate(:fp_plus, metering_point_id: @metering_point4.id, operand_id: @metering_point.id)
      @metering_point4.formula_parts << Fabricate(:fp_plus, metering_point_id: @metering_point4.id, operand_id: @metering_point2.id)
      @metering_point4.save
      @user.add_role :manager, @metering_point4

      visit "/metering_points/#{@metering_point4.id}"

      click_on 'Edit'

      click_on 'Add Formula Part'

      find("#formula_parts").all(".nested-fields").last.find(:css, "select[id^='metering_point_formula_parts_attributes_'][id$='_operand_id']").select("#{@metering_point3.name}")

      click_on 'submit'

      visit "/metering_points/#{@metering_point4.id}"

      click_on 'Edit'

      expect(find(".modal-body").find("#formula_parts")).to have_selector('select', count: 6)
    end

    it 'try to remove formula_part from virtual metering_point', :retry => 3 do
      @metering_point3 = Fabricate(:mp_hof_butenland_wind)
      @meter = Fabricate(:meter, smart: true, online: true, init_reading: true)
      @metering_point3.meter = @meter
      @metering_point3.save
      @user.add_role :manager, @metering_point3

      @metering_point4 = Fabricate(:metering_point, virtual: true)
      @metering_point4.formula_parts << Fabricate(:fp_plus, metering_point_id: @metering_point4.id, operand_id: @metering_point.id)
      @metering_point4.formula_parts << Fabricate(:fp_plus, metering_point_id: @metering_point4.id, operand_id: @metering_point2.id)
      @metering_point4.formula_parts << Fabricate(:fp_plus, metering_point_id: @metering_point4.id, operand_id: @metering_point3.id)
      @metering_point4.save
      @user.add_role :manager, @metering_point4

      visit "/metering_points/#{@metering_point4.id}"

      click_on 'Edit'

      find("#formula_parts").all(".nested-fields").last.find(".btn").trigger('click')

      click_on 'submit'

      visit "/metering_points/#{@metering_point4.id}"

      click_on 'Edit'

      expect(find(".modal-body").find("#formula_parts")).to have_selector('select', count: 4)
    end
  end
end