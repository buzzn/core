# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
Register::Base.reset_column_information
Register::Virtual.reset_column_information
Register::Input.reset_column_information
Register::Output.reset_column_information
Register::Real.reset_column_information

def user_with_register
  register = Fabricate(:register)
  user     = Fabricate(:user)
  user.add_role(:member, register)
  user.add_role :manager, register
  return user, register
end



puts '-- seed development database --'

puts '  organizations'
Fabricate(:buzzn_energy)
Fabricate(:dummy_energy)
Fabricate(:electricity_supplier, name: 'E.ON')
Fabricate(:electricity_supplier, name: 'RWE')
Fabricate(:electricity_supplier, name: 'EnBW')
Fabricate(:electricity_supplier, name: 'Vattenfall')

Fabricate(:transmission_system_operator, name: '50Hertz Transmission')
Fabricate(:transmission_system_operator, name: 'Tennet TSO')
Fabricate(:transmission_system_operator, name: 'Amprion')
Fabricate(:transmission_system_operator, name: 'TransnetBW')

# Verteilnetzbetreiber (Verteilung an private Haushalte und Kleinverbraucher)
Fabricate(:distribution_system_operator, name: 'Vattenfall Distribution Berlin GmbH')
Fabricate(:distribution_system_operator, name: 'E.ON Bayern AG')
Fabricate(:distribution_system_operator, name: 'RheinEnergie AG')

# Messdienstleistung (Ablesung und Messung)
Fabricate(:buzzn_metering)
Fabricate(:buzzn_reader)
Fabricate(:dummy)
Fabricate(:discovergy)
Fabricate(:mysmartgrid)


buzzn_team_names = %w[ felix justus danusch thomas stefan philipp christian kristian pavel eva ]
buzzn_team = []
buzzn_team_names.each do |user_name|
  puts "  #{user_name}"
  buzzn_team << user = Fabricate(user_name)
  case user_name
  when 'justus'
    easymeter_60139082 = Fabricate(:easymeter_60139082)
    easymeter_60139082.broker = Fabricate(:discovergy_broker, mode: 'in_out', external_id: "EASYMETER_60139082", resource: easymeter_60139082)
    @register_z1a = easymeter_60139082.registers.first
    @register_z1b = easymeter_60139082.registers.last
    root_register = @register_z1a
    user.add_role :manager, @register_z1a
    user.add_role :manager, @register_z1b
    easymeter_60051599 = Fabricate(:easymeter_60051599)
    easymeter_60051599.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_60051599", resource: easymeter_60051599)
    @register_z2 = easymeter_60051599.registers.first
    user.add_role :manager, @register_z2
    easymeter_60051559 = Fabricate(:easymeter_60051559)
    easymeter_60051559.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_60051559", resource: easymeter_60051559)
    @register_z3 = easymeter_60051559.registers.first
    user.add_role :manager, @register_z3
    easymeter_60051560 = Fabricate(:easymeter_60051560)
    easymeter_60051560.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_60051560", resource: easymeter_60051560)
    @register_z4 = easymeter_60051560.registers.first
    user.add_role :manager, @register_z4
    easymeter_60051600 = Fabricate(:easymeter_60051600)
    easymeter_60051600.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_60051600", resource: easymeter_60051600)
    @register_z5 = easymeter_60051600.registers.first
    user.add_role :manager, @register_z5


    dach_pv_justus = Fabricate(:dach_pv_justus)
    @register_z2.devices << dach_pv_justus
    user.add_role :manager, dach_pv_justus

    bhkw_justus        = Fabricate(:bhkw_justus)
    @register_z4.devices << bhkw_justus
    user.add_role :manager, bhkw_justus

    auto_justus        = Fabricate(:auto_justus)
    @register_z3.devices << auto_justus
    user.add_role :manager, auto_justus

  when 'felix'
    @gocycle = Fabricate(:gocycle)
    user.add_role :manager, @gocycle
    user.add_role :admin # felix is admin
    #root_register = Fabricate(:register_urbanstr88)
    #root_register.devices << @gocycle

    if Rails.env.development?
      Fabricate(:application, owner: user, name: 'Buzzn API', scopes: 'simple full', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
      application = Fabricate(:application, owner: user, name: 'Buzzn RailsView', scopes: 'simple full', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob')
      Fabricate(:application, owner: user, name: 'Buzzn Ember', scopes: 'simple full', redirect_uri: 'http://localhost:4200/')
      # HACK for seed. this is normaly don via after_filter in user
      Doorkeeper::AccessToken.create(application_id: application.id, resource_owner_id: user.id, scopes: 'simple full' )
    end

    Fabricate(:application, owner: user, name: 'Buzzn Swagger UI', scopes: Doorkeeper.configuration.scopes, redirect_uri: Rails.application.secrets.hostname + '/api/o2c.html')
  when 'christian'
    meter = Fabricate(:easymeter_60138988)
    root_register = meter.input_register
    meter.broker = Fabricate(:discovergy_broker,
      mode: 'in',
      external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}",
      resource: meter,
      provider_login: 'christian@buzzn.net',
      provider_password: 'Roentgen11smartmeter'
    )
    user.add_role :admin # christian is admin
  when 'philipp'
    meter = Fabricate(:easymeter_60009269)
    root_register = meter.input_register
    meter.broker = Fabricate(:discovergy_broker,
      mode: 'in',
      external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}",
      resource: meter,
      provider_login: 'info@philipp-osswald.de',
      provider_password: 'Null8fünfzehn'
    )
  when 'stefan'
    bhkw_stefan       = Fabricate(:bhkw_stefan)
    meter = Fabricate(:easymeter_1024000034)
    root_register = meter.output_register
    root_register.devices << bhkw_stefan
    user.add_role :manager, bhkw_stefan
  when 'thomas'
    meter = Fabricate(:easymeter_60232499)
    root_register = meter.input_register
    user.add_role :admin # thomas is admin
  when 'kristian'
    root_register = Fabricate(:input_meter).input_register
    user.add_role :admin # kristian is admin
  else
    root_register = Fabricate(:input_meter).input_register
  end
  if root_register
    user.add_role :manager, root_register
    user.add_role(:member, root_register)
  end

end

puts 'friendships for buzzn team ...'
buzzn_team.each do |user|
  buzzn_team.each do |friend|
    user.friendships.create(friend: friend) if user != friend
  end
end

uxtest_user = Fabricate(:uxtest_user)



#hof_butenland
# jan_gerdes = Fabricate(:jan_gerdes)
# register_hof_butenland_wind   = Fabricate(:register_hof_butenland_wind)
# jan_gerdes.add_role :manager, register_hof_butenland_wind
# device = Fabricate(:hof_butenland_wind)
# register_hof_butenland_wind.devices << device
# jan_gerdes.add_role :manager, device



# karin
meter = Fabricate(:easymeter_60051431)
register_pv_karin = meter.output_register
karin = Fabricate(:karin)
meter.broker = Fabricate(:discovergy_broker,
  mode: 'out',
  external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}",
  resource: meter,
  provider_login: 'karin.smith@solfux.de',
  provider_password: '19200buzzn'
)

buzzn_team.each do |buzzn_user|
  karin.friendships.create(friend: buzzn_user) # alle von buzzn sind freund von karin
  buzzn_user.friendships.create(friend: karin)
end

#Dieser User wird allen Kommentaren von gelöschten Benutzern zugewiesen
geloeschter_benutzer = Fabricate(:geloeschter_benutzer)







# puts '20 more users with location'
# 20.times do
#   user, location, register = user_with_location
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   puts "  #{user.email}"
# end



puts 'group karin strom'
karins_pv_group = Fabricate(:tribe_karins_pv_strom, registers: [register_pv_karin])
karin.add_role :manager, karins_pv_group
karins_pv_group.registers << User.where(email: 'christian@buzzn.net').first.accessible_registers.first
karins_pv_group.registers << User.where(email: 'philipp@buzzn.net').first.accessible_registers.first
karins_pv_group.registers << User.where(email: 'thomas@buzzn.net').first.accessible_registers.first
#karins_pv_group.create_activity key: 'group.create', owner: karin, recipient: karins_pv_group



puts 'Localpool Hopf'
hdh   = Fabricate(:user)
maba  = Fabricate(:user)
thoho = Fabricate(:user)

register_60118470 = Fabricate(:easymeter_60118470).output_register
hdh.add_role :manager, register_60118470
meter = register_60118470.meter
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )

register_60009316 = Fabricate(:easymeter_60009316).output_register
hdh.add_role :manager, register_60009316
meter = register_60009316.meter
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )

register_60009272 = Fabricate(:easymeter_60009272).input_register
thoho.add_role :manager, register_60009272
meter = register_60009272.meter
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )

register_60009348 = Fabricate(:easymeter_60009348).input_register
maba.add_role :manager, register_60009348
meter = register_60009348.meter
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )

register_hdh = Fabricate(:virtual_meter_hopf).register
hdh.add_role :manager, register_hdh
Fabricate(:fp_plus, operand_id: register_60009348.id, register: register_hdh)
Fabricate(:fp_plus, operand_id: register_60009316.id, register: register_hdh)

thoho.add_role :member, register_60009272
maba.add_role :member, register_60009348
hdh.add_role :member, register_60009316
hdh.add_role :member, register_hdh


localpool_hopf = Fabricate(:localpool_hopf, registers: [register_60009316])
localpool_hopf.registers << register_60009272
localpool_hopf.registers << register_60009348
localpool_hopf.registers << register_hdh



# puts 'group hof_butenland'
# group_hof_butenland = Fabricate(:group_hof_butenland, registers: [register_hof_butenland_wind])
# jan_gerdes.add_role :manager, group_hof_butenland
# 15.times do
#   user, register = user_with_register
#   group_hof_butenland.registers << register
#   puts "  #{user.email}"
# end

# christian_schuetze


meter = Fabricate(:easymeter_1124001747)
@fichtenweg10 = register_cs_1 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )



# virtual register for Justus' consumption
@fichtenweg8 = Fabricate(:virtual_meter_fichtenweg8).register
Fabricate(:fp_plus, operand: @register_z2, register: @fichtenweg8)
Fabricate(:fp_plus, operand: @register_z4, register: @fichtenweg8)
Fabricate(:fp_plus, operand: @register_z1a, register: @fichtenweg8)
Fabricate(:fp_minus, operand: @fichtenweg10, register: @fichtenweg8)
Fabricate(:fp_minus, operand: @register_z1b, register: @fichtenweg8)




puts 'Localpool home_of_the_brave'
localpool_home_of_the_brave = Fabricate(:localpool_home_of_the_brave, registers: [@register_z2, @register_z4, @fichtenweg10, @fichtenweg8])
justus = User.where(email: 'justus@buzzn.net').first
justus.add_role :manager, localpool_home_of_the_brave
justus.add_role :manager, @fichtenweg8
#localpool_home_of_the_brave.create_activity key: 'group.create', owner: justus, recipient: localpool_home_of_the_brave



puts 'Localpool wagnis4'
dimi = Fabricate(:user)
meter = Fabricate(:easymeter_60009416)
register_60009416 = meter.input_register
dimi.add_role(:manager, register_60009416)
dimi.add_role(:member, register_60009416)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


madm = Fabricate(:user)
meter = Fabricate(:easymeter_60009419)
register_60009419 = meter.input_register
madm.add_role(:manager, register_60009419)
madm.add_role(:member, register_60009419)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


siah = Fabricate(:user)
meter = Fabricate(:easymeter_60009415)
register_60009415 = meter.input_register
siah.add_role(:manager, register_60009415)
siah.add_role(:member, register_60009415)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


nisa = Fabricate(:user)
meter = Fabricate(:easymeter_60009418)
register_60009418 = meter.input_register
nisa.add_role(:manager, register_60009418)
nisa.add_role(:member, register_60009418)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


jone = Fabricate(:user)
meter = Fabricate(:easymeter_60009411)
register_60009411 = meter.input_register
jone.add_role(:manager, register_60009411)
jone.add_role(:member, register_60009411)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


elch = Fabricate(:user)
meter = Fabricate(:easymeter_60009410)
register_60009410 = meter.input_register
elch.add_role(:manager, register_60009410)
elch.add_role(:member, register_60009410)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


flbu = Fabricate(:user)
meter = Fabricate(:easymeter_60009407)
register_60009407 = meter.input_register
flbu.add_role(:manager, register_60009407)
flbu.add_role(:member, register_60009407)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


ulbe = Fabricate(:user)
meter = Fabricate(:easymeter_60009409)
register_60009409 = meter.input_register
ulbe.add_role(:manager, register_60009409)
ulbe.add_role(:member, register_60009409)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


ruha = Fabricate(:user)
meter = Fabricate(:easymeter_60009435)
register_60009435 = meter.input_register
ruha.add_role(:manager, register_60009435)
ruha.add_role(:member, register_60009435)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


mamu = Fabricate(:user)
meter = Fabricate(:easymeter_60009402)
register_60009402 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


meter = Fabricate(:easymeter_60009390)
register_60009390 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
mamu.add_role(:manager, register_60009402)
mamu.add_role(:manager, register_60009390)
mamu.add_role(:member, register_60009402)
mamu.add_role(:member, register_60009390)


ansc = Fabricate(:user)
meter = Fabricate(:easymeter_60009387)
register_60009387 = meter.input_register
ansc.add_role(:manager, register_60009387)
ansc.add_role(:member, register_60009387)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


luwo = Fabricate(:user)
meter = Fabricate(:easymeter_60009438)
register_60009438 = meter.input_register
luwo.add_role(:manager, register_60009438)
luwo.add_role(:member, register_60009438)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


pewa = Fabricate(:user)
meter = Fabricate(:easymeter_60009440)
register_60009440 = meter.input_register
pewa.add_role(:manager, register_60009440)
pewa.add_role(:member, register_60009440)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


sicy = Fabricate(:user)
meter = Fabricate(:easymeter_60009404)
register_60009404 = meter.input_register
sicy.add_role(:manager, register_60009404)
sicy.add_role(:member, register_60009404)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


dikl = Fabricate(:user)
meter = Fabricate(:easymeter_60009405)
register_60009405 = meter.input_register
dikl.add_role(:manager, register_60009405)
dikl.add_role(:member, register_60009405)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


wiwa = Fabricate(:user)
meter = Fabricate(:easymeter_60009422)
register_60009422 = meter.input_register
wiwa.add_role(:manager, register_60009422)
wiwa.add_role(:member, register_60009422)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


vole = Fabricate(:user)
meter = Fabricate(:easymeter_60009425)
register_60009425 = meter.input_register
vole.add_role(:manager, register_60009425)
vole.add_role(:member, register_60009425)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


evpf = Fabricate(:user)
meter = Fabricate(:easymeter_60009429)
register_60009429 = meter.input_register
evpf.add_role(:manager, register_60009429)
evpf.add_role(:member, register_60009429)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


dast = Fabricate(:user)
meter = Fabricate(:easymeter_60009393)
register_60009393 = meter.input_register
dast.add_role(:manager, register_60009393)
dast.add_role(:member, register_60009393)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


dokn = Fabricate(:user)
meter = Fabricate(:easymeter_60009442)
register_60009442 = meter.input_register
dokn.add_role(:manager, register_60009442)
dokn.add_role(:member, register_60009442)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


sadu = Fabricate(:user)
meter = Fabricate(:easymeter_60009441)
register_60009441 = meter.input_register
sadu.add_role(:manager, register_60009441)
sadu.add_role(:member, register_60009441)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


meter = Fabricate(:easymeter_60009420)
register_60009420 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
madm.add_role(:manager, register_60009420)

meter = Fabricate(:easymeter_60118460)
register_60118460 = meter.output_register
madm.add_role(:manager, register_60118460)
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


localpool_wagnis4 = Fabricate(:localpool_wagnis4, registers: [register_60118460])
localpool_wagnis4.registers << register_60009416
localpool_wagnis4.registers << register_60009419
localpool_wagnis4.registers << register_60009415
localpool_wagnis4.registers << register_60009418
localpool_wagnis4.registers << register_60009411
localpool_wagnis4.registers << register_60009410
localpool_wagnis4.registers << register_60009407
localpool_wagnis4.registers << register_60009409
localpool_wagnis4.registers << register_60009435
localpool_wagnis4.registers << register_60009420
localpool_wagnis4.registers << register_60009390
localpool_wagnis4.registers << register_60009402
localpool_wagnis4.registers << register_60009387
localpool_wagnis4.registers << register_60009438
localpool_wagnis4.registers << register_60009440
localpool_wagnis4.registers << register_60009404
localpool_wagnis4.registers << register_60009405
localpool_wagnis4.registers << register_60009422
localpool_wagnis4.registers << register_60009425
localpool_wagnis4.registers << register_60009429 if register_60009429
localpool_wagnis4.registers << register_60009393
localpool_wagnis4.registers << register_60009442
localpool_wagnis4.registers << register_60009441

madm.add_role(:manager, localpool_wagnis4)


puts 'Localpool hell & warm forstenried'
#Ab hier: Hell & Warm (Forstenried)
pesc = Fabricate(:pesc)
hell_und_warm = Fabricate(:hell_und_warm)
pesc.add_role(:manager, hell_und_warm)

# Übergabe in out
meter = Fabricate(:easymeter_1305004864)
register_1305004864_out = meter.output_register
register_1305004864 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in_out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
pesc.add_role(:manager, register_1305004864)
pesc.add_role(:manager, register_1305004864_out)

# Abgrenzung PV
meter = Fabricate(:easymeter_60009484)
register_60009484 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
pesc.add_role(:manager, register_60009484)

# BHKW 1
meter = Fabricate(:easymeter_60138947)
register_60138947 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
pesc.add_role(:manager, register_60138947)

# BHKW 2
meter = Fabricate(:easymeter_60138943)
register_60138943 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
pesc.add_role(:manager, register_60138943)

# PV
meter = Fabricate(:easymeter_1338000816)
register_1338000816 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
pesc.add_role(:manager, register_1338000816)

### Localpool ###

localpool_forstenried = Fabricate(:localpool_forstenried, registers: [register_60138947, register_60138943, register_1338000816])
pesc.add_role(:manager, localpool_forstenried)
localpool_forstenried.registers << register_60009484
localpool_forstenried.registers << register_1305004864
localpool_forstenried.registers << register_1305004864_out
lpc_forstenried = Fabricate(:lpc_forstenried, signing_user: pesc, localpool: localpool_forstenried, customer: hell_und_warm)
mpoc_forstenried = Fabricate(:mpoc_forstenried, signing_user: pesc, localpool: localpool_forstenried, customer: hell_und_warm)

### LSN ####

mabe = Fabricate(:mabe)
meter = Fabricate(:easymeter_60051595)
register_60051595 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
mabe.add_role(:manager, register_60051595)
mabe.add_role(:member, register_60051595)
localpool_forstenried.registers << register_60051595
lptc = Fabricate(:lptc_mabe, signing_user: mabe, register: register_60051595, customer: mabe, contractor: hell_und_warm)
#mabe.friends << pesc

inbr = Fabricate(:inbr)
meter = Fabricate(:easymeter_60051547)
register_60051547 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
inbr.add_role(:manager, register_60051547)
inbr.add_role(:member, register_60051547)
localpool_forstenried.registers << register_60051547
lptc = Fabricate(:lptc_inbr, signing_user: inbr, register: register_60051547, customer: inbr, contractor: hell_und_warm)
#inbr.friends << pesc

pebr = Fabricate(:pebr)
meter = Fabricate(:easymeter_60051620)
register_60051620 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
pebr.add_role(:manager, register_60051620)
pebr.add_role(:member, register_60051620)
localpool_forstenried.registers << register_60051620
lptc = Fabricate(:lptc_pebr, signing_user: pebr, register: register_60051620, customer: pebr, contractor: hell_und_warm)
#pebr.friends << pesc

anbr = Fabricate(:anbr)
meter = Fabricate(:easymeter_60051602)
register_60051602 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
anbr.add_role(:manager, register_60051602)
anbr.add_role(:member, register_60051602)
localpool_forstenried.registers << register_60051602
lptc = Fabricate(:lptc_anbr, signing_user: anbr, register: register_60051602, customer: anbr, contractor: hell_und_warm)
#anbr.friends << pesc

gubr = Fabricate(:gubr)
meter = Fabricate(:easymeter_60051618)
register_60051618 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
gubr.add_role(:manager, register_60051618)
gubr.add_role(:member, register_60051618)
localpool_forstenried.registers << register_60051618
lptc = Fabricate(:lptc_gubr, signing_user: gubr, register: register_60051618, customer: gubr, contractor: hell_und_warm)
#gubr.friends << pesc

mabr = Fabricate(:mabr)
meter = Fabricate(:easymeter_60051557)
register_60051557 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
mabr.add_role(:manager, register_60051557)
mabr.add_role(:member, register_60051557)
localpool_forstenried.registers << register_60051557
lptc = Fabricate(:lptc_mabr, signing_user: mabr, register: register_60051557, customer: mabr, contractor: hell_und_warm)
#mabr.friends << pesc

dabr = Fabricate(:dabr)
meter = Fabricate(:easymeter_60051596)
register_60051596 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
dabr.add_role(:manager, register_60051596)
dabr.add_role(:member, register_60051596)
localpool_forstenried.registers << register_60051596
lptc = Fabricate(:lptc_dabr, signing_user: dabr, register: register_60051596, customer: dabr, contractor: hell_und_warm)
#dabr.friends << pesc

zubu = Fabricate(:zubu)
meter = Fabricate(:easymeter_60051558)
register_60051558 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
zubu.add_role(:manager, register_60051558)
zubu.add_role(:member, register_60051558)
localpool_forstenried.registers << register_60051558
lptc = Fabricate(:lptc_zubu, signing_user: zubu, register: register_60051558, customer: zubu, contractor: hell_und_warm)
#zubu.friends << pesc

mace = Fabricate(:mace)
meter = Fabricate(:easymeter_60051551)
register_60051551 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
mace.add_role(:manager, register_60051551)
mace.add_role(:member, register_60051551)
localpool_forstenried.registers << register_60051551
lptc = Fabricate(:lptc_mace, signing_user: mace, register: register_60051551, customer: mace, contractor: hell_und_warm)
#mace.friends << pesc

stcs = Fabricate(:stcs)
meter = Fabricate(:easymeter_60051619)
register_60051619 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
stcs.add_role(:manager, register_60051619)
stcs.add_role(:member, register_60051619)
localpool_forstenried.registers << register_60051619
lptc = Fabricate(:lptc_stcs, signing_user: stcs, register: register_60051619, customer: stcs, contractor: hell_und_warm)
#stcs.friends << pesc

pafi = Fabricate(:pafi)
meter = Fabricate(:easymeter_60051556)
register_60051556 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
localpool_forstenried.registers << register_60051556
lptc = Fabricate(:lptc_pafi, signing_user: pafi, register: register_60051556, customer: pafi, contractor: hell_und_warm)
#pafi.friends << pesc

#this is the user that lives in S 33 after partick_fierley moved out
raja = Fabricate(:raja)
raja.add_role(:manager, register_60051556)
raja.add_role(:member, register_60051556)
lptc = Fabricate(:lptc_raja, signing_user: raja, register: register_60051556, customer: raja, contractor: hell_und_warm)

# mafr = Fabricate(:user)
# meter = Fabricate(:easymeter_60051617)
# register_60051617 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# mafr.add_role(:manager, register_60051617)
# mafr.add_role(:member, register_60051617)
# #mafr.friends << pesc

# evga = Fabricate(:user)
# meter = Fabricate(:easymeter_60051555)
# register_60051555 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# evga.add_role(:manager, register_60051555)
# evga.add_role(:member, register_60051555)
# #evga.friends << pesc

# chgu = Fabricate(:user)
# meter = Fabricate(:easymeter_60051616)
# register_60051616 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# chgu.add_role(:manager, register_60051616)
# chgu.add_role(:member, register_60051616)
# #chgu.friends << pesc

# gihe = Fabricate(:user)
# meter = Fabricate(:easymeter_60051615)
# register_60051615 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# gihe.add_role(:manager, register_60051615)
# gihe.add_role(:member, register_60051615)
# #gihe.friends << pesc

# uwhe = Fabricate(:user)
# meter = Fabricate(:easymeter_60051546)
# register_60051546 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# uwhe.add_role(:manager, register_60051546)
# uwhe.add_role(:member, register_60051546)
# #uwhe.friends << pesc

# anka = Fabricate(:user)
# meter = Fabricate(:easymeter_60051553)
# register_60051553 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# anka.add_role(:manager, register_60051553)
# anka.add_role(:member, register_60051553)
# #anka.friends << pesc

# reko = Fabricate(:user)
# meter = Fabricate(:easymeter_60051601)
# register_60051601 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# reko.add_role(:manager, register_60051601)
# reko.add_role(:member, register_60051601)
# #reko.friends << pesc

# thlo = Fabricate(:user)
# meter = Fabricate(:easymeter_60051568)
# register_60051568 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# thlo.add_role(:manager, register_60051568)
# thlo.add_role(:member, register_60051568)
# #thlo.friends << pesc

# luma = Fabricate(:user)
# meter = Fabricate(:easymeter_60051610)
# register_60051610 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# luma.add_role(:manager, register_60051610)
# luma.add_role(:member, register_60051610)
# #luma.friends << pesc

# frpe = Fabricate(:user)
# meter = Fabricate(:easymeter_60051537)
# register_60051537 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# frpe.add_role(:manager, register_60051537)
# frpe.add_role(:member, register_60051537)
# #frpe.friends << pesc

# anpf = Fabricate(:user)
# meter = Fabricate(:easymeter_60051564)
# register_60051564 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# anpf.add_role(:manager, register_60051564)
# anpf.add_role(:member, register_60051564)
# #anpf.friends << pesc

# coro = Fabricate(:user)
# meter = Fabricate(:easymeter_60051572)
# register_60051572 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# coro.add_role(:manager, register_60051572)
# coro.add_role(:member, register_60051572)
# #coro.friends << pesc

# chvo = Fabricate(:user)
# meter = Fabricate(:easymeter_60051552)
# register_60051552 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# chvo.add_role(:manager, register_60051552)
# chvo.add_role(:member, register_60051552)
# #chvo.friends << pesc

# clwe = Fabricate(:user)
# meter = Fabricate(:easymeter_60051567)
# register_60051567 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# clwe.add_role(:manager, register_60051567)
# clwe.add_role(:member, register_60051567)
# #clwe.friends << pesc

# siba = Fabricate(:user)
# meter = Fabricate(:easymeter_60051586)
# register_60051586 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# siba.add_role(:manager, register_60051586)
# siba.add_role(:member, register_60051586)
# #siba.friends << pesc

# laura_häusler = Fabricate(:user)
# meter = Fabricate(:easymeter_60051540)
# register_60051540 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# laura_häusler.add_role(:manager, register_60051540)
# laura_häusler.add_role(:member, register_60051540)
# #laura_häusler.friends << pesc

# bahe = Fabricate(:user)
# meter = Fabricate(:easymeter_60051578)
# register_60051578 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# bahe.add_role(:manager, register_60051578)
# bahe.add_role(:member, register_60051578)
# #bahe.friends << pesc

# daho = Fabricate(:user)
# meter = Fabricate(:easymeter_60051597)
# register_60051597 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# daho.add_role(:manager, register_60051597)
# daho.add_role(:member, register_60051597)
# #daho.friends << pesc

# ahma = Fabricate(:user)
# meter = Fabricate(:easymeter_60051541)
# register_60051541 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# ahma.add_role(:manager, register_60051541)
# ahma.add_role(:member, register_60051541)
# #ahma.friends << pesc

# mame = Fabricate(:user)
# meter = Fabricate(:easymeter_60051570)
# register_60051570 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# mame.add_role(:manager, register_60051570)
# mame.add_role(:member, register_60051570)
# #mame.friends << pesc

# wopf = Fabricate(:user)
# meter = Fabricate(:easymeter_60051548)
# register_60051548 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# wopf.add_role(:manager, register_60051548)
# wopf.add_role(:member, register_60051548)
# #wopf.friends << pesc

# math = Fabricate(:user)
# meter = Fabricate(:easymeter_60051612)
# register_60051612 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# math.add_role(:manager, register_60051612)
# math.add_role(:member, register_60051612)
# #math.friends << pesc

# kaka = Fabricate(:user)
# meter = Fabricate(:easymeter_60051549)
# register_60051549 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# kaka.add_role(:manager, register_60051549)
# kaka.add_role(:member, register_60051549)
# #kaka.friends << pesc

# chwi = Fabricate(:user)
# meter = Fabricate(:easymeter_60051587)
# register_60051587 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# chwi.add_role(:manager, register_60051587)
# chwi.add_role(:member, register_60051587)
# #chwi.friends << pesc

# dowo = Fabricate(:user)
# meter = Fabricate(:easymeter_60051566)
# register_60051566 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# dowo.add_role(:manager, register_60051566)
# dowo.add_role(:member, register_60051566)
# #dowo.friends << pesc

# eskw = Fabricate(:user)
# meter = Fabricate(:easymeter_60051592)
# register_60051592 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# eskw.add_role(:manager, register_60051592)
# eskw.add_role(:member, register_60051592)
# #eskw.friends << pesc

# fepf = Fabricate(:user)
# meter = Fabricate(:easymeter_60051580)
# register_60051580 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# fepf.add_role(:manager, register_60051580)
# fepf.add_role(:member, register_60051580)
# #fepf.friends << pesc

# jona = Fabricate(:user)
# meter = Fabricate(:easymeter_60051538)
# register_60051538 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# jona.add_role(:manager, register_60051538)
# jona.add_role(:member, register_60051538)
# #jona.friends << pesc

# ruth_jürgensen = Fabricate(:user)
# meter = Fabricate(:easymeter_60051590)
# register_60051590 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# ruth_jürgensen.add_role(:manager, register_60051590)
# ruth_jürgensen.add_role(:member, register_60051590)
# #ruth_jürgensen.friends << pesc

# raja = Fabricate(:user)
# meter = Fabricate(:easymeter_60051588)
# register_60051588 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# raja.add_role(:manager, register_60051588)
# raja.add_role(:member, register_60051588)
# #raja.friends << pesc

# elgr = Fabricate(:user)
# meter = Fabricate(:easymeter_60051543)
# register_60051543 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# elgr.add_role(:manager, register_60051543)
# elgr.add_role(:member, register_60051543)
# #elgr.friends << pesc

# mafl = Fabricate(:user)
# meter = Fabricate(:easymeter_60051582)
# register_60051582 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# mafl.add_role(:manager, register_60051582)
# mafl.add_role(:member, register_60051582)
# #mafl.friends << pesc

# michael_göbl = Fabricate(:user)
# meter = Fabricate(:easymeter_60051539)
# register_60051539 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# michael_göbl.add_role(:manager, register_60051539)
# michael_göbl.add_role(:member, register_60051539)
# #michael_göbl.friends << pesc

# jogo = Fabricate(:user)
# meter = Fabricate(:easymeter_60051545)
# register_60051545 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# jogo.add_role(:manager, register_60051545)
# jogo.add_role(:member, register_60051545)
# #jogo.friends << pesc

# paha = Fabricate(:user)
# meter = Fabricate(:easymeter_60051614)
# register_60051614 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# paha.add_role(:manager, register_60051614)
# paha.add_role(:member, register_60051614)
# #paha.friends << pesc

# guhe = Fabricate(:user)
# meter = Fabricate(:easymeter_60051550)
# register_60051550 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# guhe.add_role(:manager, register_60051550)
# guhe.add_role(:member, register_60051550)
# #guhe.friends << pesc

# dominik_sölch = Fabricate(:user)
# meter = Fabricate(:easymeter_60051573)
# register_60051573 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# dominik_sölch.add_role(:manager, register_60051573)
# dominik_sölch.add_role(:member, register_60051573)
# #dominik_sölch.friends << pesc

# jere = Fabricate(:user)
# meter = Fabricate(:easymeter_60051571)
# register_60051571 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# jere.add_role(:manager, register_60051571)
# jere.add_role(:member, register_60051571)
# #jere.friends << pesc

# ulha = Fabricate(:user)
# meter = Fabricate(:easymeter_60051544)
# register_60051544 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# ulha.add_role(:manager, register_60051544)
# ulha.add_role(:member, register_60051544)
# #ulha.friends << pesc

# anme = Fabricate(:user)
# meter = Fabricate(:easymeter_60051594)
# register_60051594 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# anme.add_role(:manager, register_60051594)
# anme.add_role(:member, register_60051594)
# #anme.friends << pesc

# aler = Fabricate(:user)
# meter = Fabricate(:easymeter_60051583)
# register_60051583 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# aler.add_role(:manager, register_60051583)
# aler.add_role(:member, register_60051583)
# #aler.friends << pesc

# kafr = Fabricate(:user)
# meter = Fabricate(:easymeter_60051604)
# register_60051604 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# kafr.add_role(:manager, register_60051604)
# kafr.add_role(:member, register_60051604)
# #kafr.friends << pesc

# clkr = Fabricate(:user)
# meter = Fabricate(:easymeter_60051593)
# register_60051593 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# clkr.add_role(:manager, register_60051593)
# clkr.add_role(:member, register_60051593)
# #clkr.friends << pesc

# raab = Fabricate(:user)
# meter = Fabricate(:easymeter_60051613)
# register_60051613 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# raab.add_role(:manager, register_60051613)
# raab.add_role(:member, register_60051613)
# #raab.friends << pesc

# mofe = Fabricate(:user)
# meter = Fabricate(:easymeter_60051611)
# register_60051611 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# mofe.add_role(:manager, register_60051611)
# mofe.add_role(:member, register_60051611)
# #mofe.friends << pesc

# irlo = Fabricate(:user)
# meter = Fabricate(:easymeter_60051609)
# register_60051609 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# irlo.add_role(:manager, register_60051609)
# irlo.add_role(:member, register_60051609)
# #irlo.friends << pesc

# eusc = Fabricate(:user)
# meter = Fabricate(:easymeter_60051554)
# register_60051554 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# eusc.add_role(:manager, register_60051554)
# eusc.add_role(:member, register_60051554)
# #eusc.friends << pesc

# sast = Fabricate(:user)
# meter = Fabricate(:easymeter_60051585)
# register_60051585 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# sast.add_role(:manager, register_60051585)
# sast.add_role(:member, register_60051585)
# #sast.friends << pesc

# havo = Fabricate(:user)
# meter = Fabricate(:easymeter_60051621)
# register_60051621 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# havo.add_role(:manager, register_60051621)
# havo.add_role(:member, register_60051621)
# #havo.friends << pesc

# rowe = Fabricate(:user)
# meter = Fabricate(:easymeter_60051565)
# register_60051565 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# rowe.add_role(:manager, register_60051565)
# rowe.add_role(:member, register_60051565)
# #rowe.friends << pesc

#TODO: meter number should be 60051565
# albr = Fabricate(:user)
# meter = Fabricate(:easymeter_60051595)
# register_60051595 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# register_60051595 = Fabricate(:register_60051595)
# albr.add_role(:manager, register_60051595)
# albr.add_role(:member, register_60051595)
#albr.friends << pesc

# swgg = Fabricate(:user)
# meter = Fabricate(:easymeter_60051579)
# register_60051579 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# swgg.add_role(:manager, register_60051579)
# swgg.add_role(:member, register_60051579)
# #swgg.friends << pesc

# thirdparty supplied N 42
meter = Fabricate(:easymeter_60051575)
register_60051575 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
pesc.add_role(:manager, register_60051575)
localpool_forstenried.registers << register_60051575

# Waldorfschule
meter = Fabricate(:easymeter_60009485)
register_60009485 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
pesc.add_role(:manager, register_60009485)
localpool_forstenried.registers << register_60009485

# Hausstrom Mitte
meter = Fabricate(:easymeter_1338000818)
register_1338000818 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
pesc.add_role(:manager, register_1338000818)
localpool_forstenried.registers << register_1338000818



# register_virtual_forstenried_erzeugung = Fabricate(:register_forstenried_erzeugung)
# register_virtual_forstenried_erzeugung.formula_parts << Fabricate(:fp_plus, operand_id: register_60138947.id)
# register_virtual_forstenried_erzeugung.formula_parts << Fabricate(:fp_plus, operand_id: register_60138943.id)
# register_virtual_forstenried_erzeugung.formula_parts << Fabricate(:fp_plus, operand_id: register_1338000816.id)
# pesc.add_role(:manager, register_virtual_forstenried_erzeugung)
# pesc.dashboard.registers << register_virtual_forstenried_erzeugung





# localpool_forstenried.registers << register_60051620
# localpool_forstenried.registers << register_60051602
# localpool_forstenried.registers << register_60051618
# localpool_forstenried.registers << register_60051557
# localpool_forstenried.registers << register_60051596
# localpool_forstenried.registers << register_60051558
# localpool_forstenried.registers << register_60051551
# localpool_forstenried.registers << register_60051619
# localpool_forstenried.registers << register_60051556
# localpool_forstenried.registers << register_60051617
# localpool_forstenried.registers << register_60051555
# localpool_forstenried.registers << register_60051616
# localpool_forstenried.registers << register_60051615
# localpool_forstenried.registers << register_60051546
# localpool_forstenried.registers << register_60051553
# localpool_forstenried.registers << register_60051601
# localpool_forstenried.registers << register_60051568
# localpool_forstenried.registers << register_60051610
# localpool_forstenried.registers << register_60051537
# localpool_forstenried.registers << register_60051564
# localpool_forstenried.registers << register_60051572
# localpool_forstenried.registers << register_60051552
# localpool_forstenried.registers << register_60051567
# localpool_forstenried.registers << register_60051586
# localpool_forstenried.registers << register_60051540
# localpool_forstenried.registers << register_60051578
# localpool_forstenried.registers << register_60051597
# localpool_forstenried.registers << register_60051541
# localpool_forstenried.registers << register_60051570
# localpool_forstenried.registers << register_60051548
# localpool_forstenried.registers << register_60051612
# localpool_forstenried.registers << register_60051549
# localpool_forstenried.registers << register_60051587
# localpool_forstenried.registers << register_60051566
# localpool_forstenried.registers << register_60051592
# localpool_forstenried.registers << register_60051580
# localpool_forstenried.registers << register_60051538
# localpool_forstenried.registers << register_60051590
# localpool_forstenried.registers << register_60051588
# localpool_forstenried.registers << register_60051543
# localpool_forstenried.registers << register_60051582
# localpool_forstenried.registers << register_60051539
# localpool_forstenried.registers << register_60051545
# localpool_forstenried.registers << register_60051614
# localpool_forstenried.registers << register_60051550
# localpool_forstenried.registers << register_60051573
# localpool_forstenried.registers << register_60051571
# localpool_forstenried.registers << register_60051544
# localpool_forstenried.registers << register_60051594
# localpool_forstenried.registers << register_60051583
# localpool_forstenried.registers << register_60051604
# localpool_forstenried.registers << register_60051593
# localpool_forstenried.registers << register_60051613
# localpool_forstenried.registers << register_60051611
# localpool_forstenried.registers << register_60051609
# localpool_forstenried.registers << register_60051554
# localpool_forstenried.registers << register_60051585
# localpool_forstenried.registers << register_60051621
# localpool_forstenried.registers << register_60051565
#localpool_forstenried.registers << register_60051579



#localpool_forstenried.brokers << Fabricate(:discovergy_broker, mode: 'in', external_id: "VIRTUAL_00000077", resource: localpool_forstenried )
#
# register_virtual_forstenried_bezug = Fabricate(:register_forstenried_bezug)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051595.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051547.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051620.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051602.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051618.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051557.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051596.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051558.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051551.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051619.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051556.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051617.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051555.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051616.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051615.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051546.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051553.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051601.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051568.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051610.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051537.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051564.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051572.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051552.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051567.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051586.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051540.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051578.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051597.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051541.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051570.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051548.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051612.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051549.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051587.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051566.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051592.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051580.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051538.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051590.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051588.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051543.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051582.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051539.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051545.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051614.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051550.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051573.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051571.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051544.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051594.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051583.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051604.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051593.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051613.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051611.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051609.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051554.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051585.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051621.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60051565.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_60009485.id)
# register_virtual_forstenried_bezug.formula_parts << Fabricate(:fp_plus, operand_id: register_1338000818.id)
#
# pesc.add_role(:manager, register_virtual_forstenried_bezug)
# pesc.dashboard.registers << register_virtual_forstenried_bezug
#





### LCP Sulz ###
puts 'Localpool Sulz'

sulz_contractor = Fabricate(:organization, mode: 'other', name: 'HaFi', address: Fabricate(:address,
                                                                                          street_name: 'Sulz',
                                                                                          street_number: '2',
                                                                                          zip: 82380,
                                                                                          city: 'Peißenberg'))
sulz_manager = Fabricate(:user)
sulz_manager.add_role(:manager, sulz_contractor)


# Übergabe in out
meter = Fabricate(:easymeter_60300856)
register_60300856_out = meter.output_register
register_60300856 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in_out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register_60300856)
sulz_manager.add_role(:manager, register_60300856_out)
Fabricate(:reading, register_id: register_60300856.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 1100, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register_60300856.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 183900, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register_60300856_out.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 1000, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register_60300856_out.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 510200, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

# Abgrenzung bhkw
meter = Fabricate(:easymeter_60009498)
register_60009498 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register_60009498)
Fabricate(:reading, register_id: register_60009498.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 1100, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register_60009498.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 248000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

# Produktion bhkw
meter = Fabricate(:easymeter_60404855)
register_60404855 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register_60404855)
Fabricate(:reading, register_id: register_60404855.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register_60404855.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 10770500, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

# Produktion pv
meter = Fabricate(:easymeter_60404845)
register_60404845 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register_60404845)
Fabricate(:reading, register_id: register_60404845.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register_60404845.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 7060800, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

localpool_sulz = Fabricate(:localpool_sulz, registers: [register_60404855, register_60404845])
sulz_manager.add_role(:manager, localpool_sulz)
mpoc_sulz = Fabricate(:mpoc_sulz, signing_user: sulz_manager, localpool: localpool_sulz, customer: sulz_contractor)
lpc_sulz = Fabricate(:lpc_sulz, signing_user: sulz_manager, localpool: localpool_sulz, customer: sulz_contractor)

meter = Fabricate(:easymeter_60404846)
register = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register)
localpool_sulz.registers << register
user = Fabricate(:user)
user.add_role(:member, register)
orga = Fabricate(:organization, mode: 'other')
user.add_role(:manager, orga)
lptc = Fabricate(:lptc_hafi, signing_user: user, register: register, customer: orga, contractor: sulz_contractor)
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 13855000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134105, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 241100, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 239000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

meter = Fabricate(:easymeter_60404850)
register = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register)
localpool_sulz.registers << register
user = Fabricate(:user)
user.add_role(:member, register)
lptc = Fabricate(:lptc_hubv, signing_user: user, register: register, customer: user, contractor: sulz_contractor)
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 27489000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134118, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 864100, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 858000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

meter = Fabricate(:easymeter_60404851)
register = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register)
localpool_sulz.registers << register
user = Fabricate(:user)
user.add_role(:member, register)
orga = Fabricate(:organization, mode: 'other')
user.add_role(:manager, orga)
lptc = Fabricate(:lptc_mape, signing_user: user, register: register, customer: orga, contractor: sulz_contractor)
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 24124000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 49350039, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 1892400, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 1879000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

meter = Fabricate(:easymeter_60404853)
register = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register)
localpool_sulz.registers << register
user = Fabricate(:user)
user.add_role(:member, register)
orga = Fabricate(:organization, mode: 'other')
user.add_role(:manager, orga)
lptc = Fabricate(:lptc_hafi2, signing_user: user, register: register, customer: orga, contractor: sulz_contractor)

user = Fabricate(:user)
user.add_role(:member, register)
lptc = Fabricate(:lptc_pewi, signing_user: user, register: register, customer: user, contractor: sulz_contractor)
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 23790, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 4789917, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 10, 31), energy_milliwatt_hour: 191000, reason: Reading::CONTRACT_CHANGE, quality: Reading::READ_OUT, source: Reading::CUSTOMER_LSG, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 11, 1), energy_milliwatt_hour: 191000, reason: Reading::CONTRACT_CHANGE, quality: Reading::READ_OUT, source: Reading::CUSTOMER_LSG, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 808200, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 798000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')


meter = Fabricate(:easymeter_60404847)
register = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register)
localpool_sulz.registers << register
user = Fabricate(:user)
user.add_role(:member, register)
lptc = Fabricate(:lptc_musc, signing_user: user, register: register, customer: user, contractor: sulz_contractor)
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 8024000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 5640077, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 456300, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 4529000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

meter = Fabricate(:easymeter_60404854)
register = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register)
localpool_sulz.registers << register
user = Fabricate(:user)
user.add_role(:member, register)
lptc = Fabricate(:lptc_viwe, signing_user: user, register: register, customer: user, contractor: sulz_contractor)
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 19442000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 77134120, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 809700, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 805000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

meter = Fabricate(:easymeter_60404852)
register = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register)
localpool_sulz.registers << register
user = Fabricate(:user)
user.add_role(:member, register)
lptc = Fabricate(:lptc_reho, signing_user: user, register: register, customer: user, contractor: sulz_contractor)
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 9597000, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 5000705, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 1), energy_milliwatt_hour: 1523000, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 31), energy_milliwatt_hour: 1513000, reason: Reading::REGULAR_READING, quality: Reading::FORECAST_VALUE, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

meter = Fabricate(:easymeter_60327350)
register = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register)
localpool_sulz.registers << register
user = Fabricate(:user)
user.add_role(:member, register)
osc = (Fabricate(:osc_saba, signing_user: user, register: register, customer: user, contractor: sulz_contractor))

user = Fabricate(:user)
user.add_role(:member, register)
lptc = Fabricate(:lptc_saba, signing_user: user, register: register, customer: user, contractor: sulz_contractor)
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 9078000, reason: Reading::DEVICE_REMOVAL, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 4939588, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 12, 16), energy_milliwatt_hour: 9341900, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 4939588, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 1, 12), energy_milliwatt_hour: 9521100, reason: Reading::REGULAR_READING, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: 4939588, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 2, 28), energy_milliwatt_hour: 9801400, reason: Reading::DEVICE_CHANGE_1, quality: Reading::READ_OUT, source: Reading::CUSTOMER_LSG, meter_serialnumber: 4939588, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 2, 28), energy_milliwatt_hour: 733500, reason: Reading::DEVICE_CHANGE_2, quality: Reading::READ_OUT, source: Reading::CUSTOMER_LSG, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2017, 3, 1), energy_milliwatt_hour: 733500, reason: Reading::CONTRACT_CHANGE, quality: Reading::READ_OUT, source: Reading::CUSTOMER_LSG, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')

# zwischenzähler!
meter = Fabricate(:easymeter_60404849)
register = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
sulz_manager.add_role(:manager, register)
Fabricate(:reading, register_id: register.id, timestamp: Time.new(2016, 8, 4), energy_milliwatt_hour: 0, reason: Reading::DEVICE_SETUP, quality: Reading::READ_OUT, source: Reading::BUZZN_SYSTEMS, meter_serialnumber: meter.manufacturer_product_serialnumber, state: 'Z86')






puts 'send friendships requests for buzzn team'
like_to_friend = Fabricate(:user)
buzzn_team.each do |user|
  FriendshipRequest.create(sender: like_to_friend, receiver: user)
end
