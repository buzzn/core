# require 'spec_helper'


# feature 'Group' do
#   describe 'try to manage groups', :js do

#     before do
#       @karin = Fabricate(:karin)
#       @karin.contracting_party = Fabricate(:contracting_party)

#       @mp_pv_karin = Fabricate(:mp_pv_karin)
#       @karin.add_role :manager, @mp_pv_karin

#       @contract = Fabricate(:metering_point_operator_contract, organization: Fabricate(:metering_point_operator, name: 'Stadtwerke Augsburg'))
#       @mp_pv_karin.contracts << @contract
#       @mp_pv_karin.users << @karin

#       @pv_karin = Fabricate(:pv_karin)
#       @karin.add_role :manager, @pv_karin
#       @mp_pv_karin.devices << @pv_karin
#       @mp_pv_karin.contracts.metering_point_operators.first.contracting_party = @karin.contracting_party
#       @mp_pv_karin.contracts.metering_point_operators.first.save

#       visit '/users/sign_in'
#       fill_in :user_email,    :with => @karin.email
#       fill_in :user_password, :with => '12345678'
#       click_button 'Sign in'
#     end

#     it 'will be signed in' do
#       expect(page).to have_content('Signed in successfully.')
#     end

#     it 'try to create group', :retry => 3 do
#       visit "/profiles/#{@karin.profile.slug}"
#       click_on 'Create Group'
#       expect(page).to have_content('New Group')

#       find('.group_metering_points').find(:css, "input[id^='s2id_autogen']").set("PV")
#       find(".select2-drop").native.send_keys(:return)

#       fill_in :group_name,            with: 'Testgruppe'
#       fill_in :group_description,     with: 'So eine tolle Testgruppe haben wir hier.'

#       find(:css, 'input[id=submit]').trigger('click')

#       sleep 10 #wait for redirecting
#       expect(page).to have_content('Live Chart')
#     end

#     it 'will fail to create group', :retry => 3 do
#       visit "/profiles/#{@karin.profile.slug}"

#       click_on 'Create Group'

#       #fill_in :group_name,            with: 'Testgruppe'
#       #fill_in :group_description,     with: 'Das sollte niemals zu sehen sein.'

#       #click_button 'submit'
#       #expect(page).to have_content("can't be blank")

#       #find('.group_metering_points').find(:css, "input[id^='s2id_autogen']").set("PV")
#       #find(".select2-drop").native.send_keys(:return)
#       #fill_in :group_name,            with: ''
#       #fill_in :group_description,     with: 'Das sollte niemals zu sehen sein.'

#       find(:css, 'input[id=submit]').trigger('click')
#       expect(find(".group_name")).to have_content("can't be blank")
#       expect(find(".group_metering_points")).to have_content("can't be blank")
#     end

#     it 'will not be allowed to create group', :retry => 3 do
#       @user2 = Fabricate(:user)
#       @metering_point = Fabricate(:mp_60009269)
#       @user2.add_role(:manager, @metering_point)

#       find(".navbar-content").click_link "#{@karin.name}"
#       click_on 'Logout'

#       visit '/users/sign_in'
#       fill_in :user_email,    :with => @user2.email
#       fill_in :user_password, :with => '12345678'
#       click_button 'Sign in'

#       expect(page).not_to have_link "Create Group"
#     end

#     it 'will not be allowed to edit group', :retry => 3 do
#       @user2 = Fabricate(:user)
#       @metering_point = Fabricate(:mp_60009269)
#       @user2.add_role(:manager, @metering_point)
#       @group = Fabricate(:group, metering_points: [ @metering_point ])
#       @user2.add_role :manager, @group

#       visit "/groups/#{@group.slug}"

#       expect(page).not_to have_link('Edit', :href => edit_group_path(@group))
#     end
#   end
# end