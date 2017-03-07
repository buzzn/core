# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

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



puts 'Group Hopf(localpool)'
hans_dieter_hopf  = Fabricate(:hans_dieter_hopf)
manuela_baier     = Fabricate(:manuela_baier)
thomas_hopf       = Fabricate(:thomas_hopf)

register_60118470 = Fabricate(:easymeter_60118470).output_register
hans_dieter_hopf.add_role :manager, register_60118470
meter = register_60118470.meter
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )

register_60009316 = Fabricate(:easymeter_60009316).output_register
hans_dieter_hopf.add_role :manager, register_60009316
meter = register_60009316.meter
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )

register_60009272 = Fabricate(:easymeter_60009272).input_register
thomas_hopf.add_role :manager, register_60009272
meter = register_60009272.meter
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )

register_60009348 = Fabricate(:easymeter_60009348).input_register
manuela_baier.add_role :manager, register_60009348
meter = register_60009348.meter
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )

register_hans_dieter_hopf = Fabricate(:virtual_meter_hopf).register
hans_dieter_hopf.add_role :manager, register_hans_dieter_hopf
Fabricate(:fp_plus, operand_id: register_60009348.id, register: register_hans_dieter_hopf)
Fabricate(:fp_plus, operand_id: register_60009316.id, register: register_hans_dieter_hopf)

thomas_hopf.add_role :member, register_60009272
manuela_baier.add_role :member, register_60009348
hans_dieter_hopf.add_role :member, register_60009316
hans_dieter_hopf.add_role :member, register_hans_dieter_hopf


localpool_hopf = Fabricate(:localpool_hopf, registers: [register_60009316])
localpool_hopf.registers << register_60009272
localpool_hopf.registers << register_60009348
localpool_hopf.registers << register_hans_dieter_hopf



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




puts 'group home_of_the_brave'
localpool_home_of_the_brave = Fabricate(:localpool_home_of_the_brave, registers: [@register_z2, @register_z4, @fichtenweg10, @fichtenweg8])
justus = User.where(email: 'justus@buzzn.net').first
justus.add_role :manager, localpool_home_of_the_brave
justus.add_role :manager, @fichtenweg8
#localpool_home_of_the_brave.create_activity key: 'group.create', owner: justus, recipient: localpool_home_of_the_brave



puts 'group wagnis4'
dirk_mittelstaedt = Fabricate(:dirk_mittelstaedt)
meter = Fabricate(:easymeter_60009416)
register_60009416 = meter.input_register
dirk_mittelstaedt.add_role(:manager, register_60009416)
dirk_mittelstaedt.add_role(:member, register_60009416)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


manuel_dmoch = Fabricate(:manuel_dmoch)
meter = Fabricate(:easymeter_60009419)
register_60009419 = meter.input_register
manuel_dmoch.add_role(:manager, register_60009419)
manuel_dmoch.add_role(:member, register_60009419)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


sibo_ahrens = Fabricate(:sibo_ahrens)

meter = Fabricate(:easymeter_60009415)
register_60009415 = meter.input_register
sibo_ahrens.add_role(:manager, register_60009415)
sibo_ahrens.add_role(:member, register_60009415)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


nicolas_sadoni = Fabricate(:nicolas_sadoni)
meter = Fabricate(:easymeter_60009418)
register_60009418 = meter.input_register
nicolas_sadoni.add_role(:manager, register_60009418)
nicolas_sadoni.add_role(:member, register_60009418)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


josef_neu = Fabricate(:josef_neu)

meter = Fabricate(:easymeter_60009411)
register_60009411 = meter.input_register
josef_neu.add_role(:manager, register_60009411)
josef_neu.add_role(:member, register_60009411)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


elisabeth_christiansen = Fabricate(:elisabeth_christiansen)
meter = Fabricate(:easymeter_60009410)
register_60009410 = meter.input_register
elisabeth_christiansen.add_role(:manager, register_60009410)
elisabeth_christiansen.add_role(:member, register_60009410)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


florian_butz = Fabricate(:florian_butz)
meter = Fabricate(:easymeter_60009407)
register_60009407 = meter.input_register
florian_butz.add_role(:manager, register_60009407)
florian_butz.add_role(:member, register_60009407)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


ulrike_bez = Fabricate(:ulrike_bez)
meter = Fabricate(:easymeter_60009409)
register_60009409 = meter.input_register
ulrike_bez.add_role(:manager, register_60009409)
ulrike_bez.add_role(:member, register_60009409)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


rudolf_hassenstein = Fabricate(:rudolf_hassenstein)
meter = Fabricate(:easymeter_60009435)
register_60009435 = meter.input_register
rudolf_hassenstein.add_role(:manager, register_60009435)
rudolf_hassenstein.add_role(:member, register_60009435)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


maria_mueller = Fabricate(:maria_mueller)

meter = Fabricate(:easymeter_60009402)
register_60009402 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


meter = Fabricate(:easymeter_60009390)
register_60009390 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
maria_mueller.add_role(:manager, register_60009402)
maria_mueller.add_role(:manager, register_60009390)
maria_mueller.add_role(:member, register_60009402)
maria_mueller.add_role(:member, register_60009390)


andreas_schlafer = Fabricate(:andreas_schlafer)
meter = Fabricate(:easymeter_60009387)
register_60009387 = meter.input_register
andreas_schlafer.add_role(:manager, register_60009387)
andreas_schlafer.add_role(:member, register_60009387)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


luise_woerle = Fabricate(:luise_woerle)
meter = Fabricate(:easymeter_60009438)
register_60009438 = meter.input_register
luise_woerle.add_role(:manager, register_60009438)
luise_woerle.add_role(:member, register_60009438)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


peter_waechter = Fabricate(:peter_waechter)
meter = Fabricate(:easymeter_60009440)
register_60009440 = meter.input_register
peter_waechter.add_role(:manager, register_60009440)
peter_waechter.add_role(:member, register_60009440)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


sigrid_cycon = Fabricate(:sigrid_cycon)
meter = Fabricate(:easymeter_60009404)
register_60009404 = meter.input_register
sigrid_cycon.add_role(:manager, register_60009404)
sigrid_cycon.add_role(:member, register_60009404)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


dietlind_klemm = Fabricate(:dietlind_klemm)
meter = Fabricate(:easymeter_60009405)
register_60009405 = meter.input_register
dietlind_klemm.add_role(:manager, register_60009405)
dietlind_klemm.add_role(:member, register_60009405)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


wilhelm_wagner = Fabricate(:wilhelm_wagner)
meter = Fabricate(:easymeter_60009422)
register_60009422 = meter.input_register
wilhelm_wagner.add_role(:manager, register_60009422)
wilhelm_wagner.add_role(:member, register_60009422)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


volker_letzner = Fabricate(:volker_letzner)
meter = Fabricate(:easymeter_60009425)
register_60009425 = meter.input_register
volker_letzner.add_role(:manager, register_60009425)
volker_letzner.add_role(:member, register_60009425)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


evang_pflege = Fabricate(:evang_pflege)
meter = Fabricate(:easymeter_60009429)
register_60009429 = meter.input_register
evang_pflege.add_role(:manager, register_60009429)
evang_pflege.add_role(:member, register_60009429)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


david_stadlmann = Fabricate(:david_stadlmann)
meter = Fabricate(:easymeter_60009393)
register_60009393 = meter.input_register
david_stadlmann.add_role(:manager, register_60009393)
david_stadlmann.add_role(:member, register_60009393)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


doris_knaier = Fabricate(:doris_knaier)
meter = Fabricate(:easymeter_60009442)
register_60009442 = meter.input_register
doris_knaier.add_role(:manager, register_60009442)
doris_knaier.add_role(:member, register_60009442)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


sabine_dumler = Fabricate(:sabine_dumler)
meter = Fabricate(:easymeter_60009441)
register_60009441 = meter.input_register
sabine_dumler.add_role(:manager, register_60009441)
sabine_dumler.add_role(:member, register_60009441)
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )


meter = Fabricate(:easymeter_60009420)
register_60009420 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
manuel_dmoch.add_role(:manager, register_60009420)

meter = Fabricate(:easymeter_60118460)
register_60118460 = meter.output_register
manuel_dmoch.add_role(:manager, register_60118460)
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

manuel_dmoch.add_role(:manager, localpool_wagnis4)


puts 'group hell & warm forstenried'
#Ab hier: Hell & Warm (Forstenried)
peter_schmidt = Fabricate(:peter_schmidt)
hell_und_warm = Fabricate(:hell_und_warm)
peter_schmidt.add_role(:manager, hell_und_warm)

localpool_forstenried = Fabricate(:localpool_forstenried, registers: [register_60138947, register_60138943, register_1338000816])
peter_schmidt.add_role(:manager, localpool_forstenried)


markus_becher = Fabricate(:markus_becher)
meter = Fabricate(:easymeter_60051595)
register_60051595 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
markus_becher.add_role(:manager, register_60051595)
markus_becher.add_role(:member, register_60051595)
localpool_forstenried.registers << register_60051595
lptc = Fabricate(:lptc_markus_becher, signing_user: markus_becher, register: register_60051595, customer: markus_becher, contractor: hell_und_warm)
#markus_becher.friends << peter_schmidt

inge_brack = Fabricate(:inge_brack)
meter = Fabricate(:easymeter_60051547)
register_60051547 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
inge_brack.add_role(:manager, register_60051547)
inge_brack.add_role(:member, register_60051547)
localpool_forstenried.registers << register_60051547
lptc = Fabricate(:lptc_inge_brack, signing_user: inge_brack, register: register_60051547, customer: inge_brack, contractor: hell_und_warm)
#inge_brack.friends << peter_schmidt

peter_brack = Fabricate(:peter_brack)
meter = Fabricate(:easymeter_60051620)
register_60051620 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
peter_brack.add_role(:manager, register_60051620)
peter_brack.add_role(:member, register_60051620)
localpool_forstenried.registers << register_60051620
lptc = Fabricate(:lptc_peter_brack, signing_user: peter_brack, register: register_60051620, customer: peter_brack, contractor: hell_und_warm)
#peter_brack.friends << peter_schmidt

annika_brandl = Fabricate(:annika_brandl)
meter = Fabricate(:easymeter_60051602)
register_60051602 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
annika_brandl.add_role(:manager, register_60051602)
annika_brandl.add_role(:member, register_60051602)
localpool_forstenried.registers << register_60051602
lptc = Fabricate(:lptc_annika_brandl, signing_user: annika_brandl, register: register_60051602, customer: annika_brandl, contractor: hell_und_warm)
#annika_brandl.friends << peter_schmidt

gudrun_brandl = Fabricate(:gudrun_brandl)
meter = Fabricate(:easymeter_60051618)
register_60051618 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
gudrun_brandl.add_role(:manager, register_60051618)
gudrun_brandl.add_role(:member, register_60051618)
localpool_forstenried.registers << register_60051618
lptc = Fabricate(:lptc_gudrun_brandl, signing_user: gudrun_brandl, register: register_60051618, customer: gudrun_brandl, contractor: hell_und_warm)
#gudrun_brandl.friends << peter_schmidt

martin_braeunlich = Fabricate(:martin_braeunlich)
meter = Fabricate(:easymeter_60051557)
register_60051557 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
martin_braeunlich.add_role(:manager, register_60051557)
martin_braeunlich.add_role(:member, register_60051557)
localpool_forstenried.registers << register_60051557
lptc = Fabricate(:lptc_martin_braeunlich, signing_user: martin_braeunlich, register: register_60051557, customer: martin_braeunlich, contractor: hell_und_warm)
#martin_braeunlich.friends << peter_schmidt

daniel_bruno = Fabricate(:daniel_bruno)
meter = Fabricate(:easymeter_60051596)
register_60051596 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
daniel_bruno.add_role(:manager, register_60051596)
daniel_bruno.add_role(:member, register_60051596)
localpool_forstenried.registers << register_60051596
lptc = Fabricate(:lptc_daniel_bruno, signing_user: daniel_bruno, register: register_60051596, customer: daniel_bruno, contractor: hell_und_warm)
#daniel_bruno.friends << peter_schmidt

zubair_butt = Fabricate(:zubair_butt)
meter = Fabricate(:easymeter_60051558)
register_60051558 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
zubair_butt.add_role(:manager, register_60051558)
zubair_butt.add_role(:member, register_60051558)
localpool_forstenried.registers << register_60051558
lptc = Fabricate(:lptc_zubair_butt, signing_user: zubair_butt, register: register_60051558, customer: zubair_butt, contractor: hell_und_warm)
#zubair_butt.friends << peter_schmidt

maria_cerghizan = Fabricate(:maria_cerghizan)
meter = Fabricate(:easymeter_60051551)
register_60051551 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
maria_cerghizan.add_role(:manager, register_60051551)
maria_cerghizan.add_role(:member, register_60051551)
localpool_forstenried.registers << register_60051551
lptc = Fabricate(:lptc_maria_cerghizan, signing_user: maria_cerghizan, register: register_60051551, customer: maria_cerghizan, contractor: hell_und_warm)
#maria_cerghizan.friends << peter_schmidt

stefan_csizmadia = Fabricate(:stefan_csizmadia)
meter = Fabricate(:easymeter_60051619)
register_60051619 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
stefan_csizmadia.add_role(:manager, register_60051619)
stefan_csizmadia.add_role(:member, register_60051619)
localpool_forstenried.registers << register_60051619
lptc = Fabricate(:lptc_stefan_csizmadia, signing_user: stefan_csizmadia, register: register_60051619, customer: stefan_csizmadia, contractor: hell_und_warm)
#stefan_csizmadia.friends << peter_schmidt

patrick_fierley = Fabricate(:patrick_fierley)
meter = Fabricate(:easymeter_60051556)
register_60051556 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
localpool_forstenried.registers << register_60051556
lptc = Fabricate(:lptc_patrick_fierley, signing_user: patrick_fierley, register: register_60051556, customer: patrick_fierley, contractor: hell_und_warm)
#patrick_fierley.friends << peter_schmidt

#this is the user that lives in S 33 after partick_fierley moved out
rafal_jaskolka = Fabricate(:rafal_jaskolka)
rafal_jaskolka.add_role(:manager, register_60051556)
rafal_jaskolka.add_role(:member, register_60051556)
lptc = Fabricate(:lptc_rafal_jaskolka, signing_user: rafal_jaskolka, register: register_60051556, customer: rafal_jaskolka, contractor: hell_und_warm)

# maria_frank = Fabricate(:maria_frank)
# meter = Fabricate(:easymeter_60051617)
# register_60051617 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# maria_frank.add_role(:manager, register_60051617)
# maria_frank.add_role(:member, register_60051617)
# #maria_frank.friends << peter_schmidt

# eva_galow = Fabricate(:eva_galow)
# meter = Fabricate(:easymeter_60051555)
# register_60051555 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# eva_galow.add_role(:manager, register_60051555)
# eva_galow.add_role(:member, register_60051555)
# #eva_galow.friends << peter_schmidt

# christel_guesgen = Fabricate(:christel_guesgen)
# meter = Fabricate(:easymeter_60051616)
# register_60051616 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# christel_guesgen.add_role(:manager, register_60051616)
# christel_guesgen.add_role(:member, register_60051616)
# #christel_guesgen.friends << peter_schmidt

# gilda_hencke = Fabricate(:gilda_hencke)
# meter = Fabricate(:easymeter_60051615)
# register_60051615 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# gilda_hencke.add_role(:manager, register_60051615)
# gilda_hencke.add_role(:member, register_60051615)
# #gilda_hencke.friends << peter_schmidt

# uwe_hetzer = Fabricate(:uwe_hetzer)
# meter = Fabricate(:easymeter_60051546)
# register_60051546 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# uwe_hetzer.add_role(:manager, register_60051546)
# uwe_hetzer.add_role(:member, register_60051546)
# #uwe_hetzer.friends << peter_schmidt

# andreas_kapfer = Fabricate(:andreas_kapfer)
# meter = Fabricate(:easymeter_60051553)
# register_60051553 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# andreas_kapfer.add_role(:manager, register_60051553)
# andreas_kapfer.add_role(:member, register_60051553)
# #andreas_kapfer.friends << peter_schmidt

# renate_koller = Fabricate(:renate_koller)
# meter = Fabricate(:easymeter_60051601)
# register_60051601 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# renate_koller.add_role(:manager, register_60051601)
# renate_koller.add_role(:member, register_60051601)
# #renate_koller.friends << peter_schmidt

# thekla_lorber = Fabricate(:thekla_lorber)
# meter = Fabricate(:easymeter_60051568)
# register_60051568 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# thekla_lorber.add_role(:manager, register_60051568)
# thekla_lorber.add_role(:member, register_60051568)
# #thekla_lorber.friends << peter_schmidt

# ludwig_maassen = Fabricate(:ludwig_maassen)
# meter = Fabricate(:easymeter_60051610)
# register_60051610 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# ludwig_maassen.add_role(:manager, register_60051610)
# ludwig_maassen.add_role(:member, register_60051610)
# #ludwig_maassen.friends << peter_schmidt

# franz_petschler = Fabricate(:franz_petschler)
# meter = Fabricate(:easymeter_60051537)
# register_60051537 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# franz_petschler.add_role(:manager, register_60051537)
# franz_petschler.add_role(:member, register_60051537)
# #franz_petschler.friends << peter_schmidt

# anna_pfaffel = Fabricate(:anna_pfaffel)
# meter = Fabricate(:easymeter_60051564)
# register_60051564 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# anna_pfaffel.add_role(:manager, register_60051564)
# anna_pfaffel.add_role(:member, register_60051564)
# #anna_pfaffel.friends << peter_schmidt

# cornelia_roth = Fabricate(:cornelia_roth)
# meter = Fabricate(:easymeter_60051572)
# register_60051572 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# cornelia_roth.add_role(:manager, register_60051572)
# cornelia_roth.add_role(:member, register_60051572)
# #cornelia_roth.friends << peter_schmidt

# christiane_voigt = Fabricate(:christiane_voigt)
# meter = Fabricate(:easymeter_60051552)
# register_60051552 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# christiane_voigt.add_role(:manager, register_60051552)
# christiane_voigt.add_role(:member, register_60051552)
# #christiane_voigt.friends << peter_schmidt

# claudia_weber = Fabricate(:claudia_weber)
# meter = Fabricate(:easymeter_60051567)
# register_60051567 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# claudia_weber.add_role(:manager, register_60051567)
# claudia_weber.add_role(:member, register_60051567)
# #claudia_weber.friends << peter_schmidt

# sissi_banos = Fabricate(:sissi_banos)
# meter = Fabricate(:easymeter_60051586)
# register_60051586 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# sissi_banos.add_role(:manager, register_60051586)
# sissi_banos.add_role(:member, register_60051586)
# #sissi_banos.friends << peter_schmidt

# laura_häusler = Fabricate(:laura_haeusler)
# meter = Fabricate(:easymeter_60051540)
# register_60051540 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# laura_häusler.add_role(:manager, register_60051540)
# laura_häusler.add_role(:member, register_60051540)
# #laura_häusler.friends << peter_schmidt

# bastian_hentschel = Fabricate(:bastian_hentschel)
# meter = Fabricate(:easymeter_60051578)
# register_60051578 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# bastian_hentschel.add_role(:manager, register_60051578)
# bastian_hentschel.add_role(:member, register_60051578)
# #bastian_hentschel.friends << peter_schmidt

# dagmar_holland = Fabricate(:dagmar_holland)
# meter = Fabricate(:easymeter_60051597)
# register_60051597 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# dagmar_holland.add_role(:manager, register_60051597)
# dagmar_holland.add_role(:member, register_60051597)
# #dagmar_holland.friends << peter_schmidt

# ahmad_majid = Fabricate(:ahmad_majid)
# meter = Fabricate(:easymeter_60051541)
# register_60051541 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# ahmad_majid.add_role(:manager, register_60051541)
# ahmad_majid.add_role(:member, register_60051541)
# #ahmad_majid.friends << peter_schmidt

# marinus_meiners = Fabricate(:marinus_meiners)
# meter = Fabricate(:easymeter_60051570)
# register_60051570 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# marinus_meiners.add_role(:manager, register_60051570)
# marinus_meiners.add_role(:member, register_60051570)
# #marinus_meiners.friends << peter_schmidt

# wolfgang_pfaffel = Fabricate(:wolfgang_pfaffel)
# meter = Fabricate(:easymeter_60051548)
# register_60051548 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# wolfgang_pfaffel.add_role(:manager, register_60051548)
# wolfgang_pfaffel.add_role(:member, register_60051548)
# #wolfgang_pfaffel.friends << peter_schmidt

# magali_thomas = Fabricate(:magali_thomas)
# meter = Fabricate(:easymeter_60051612)
# register_60051612 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# magali_thomas.add_role(:manager, register_60051612)
# magali_thomas.add_role(:member, register_60051612)
# #magali_thomas.friends << peter_schmidt

# kathrin_kaisenberg = Fabricate(:kathrin_kaisenberg)
# meter = Fabricate(:easymeter_60051549)
# register_60051549 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# kathrin_kaisenberg.add_role(:manager, register_60051549)
# kathrin_kaisenberg.add_role(:member, register_60051549)
# #kathrin_kaisenberg.friends << peter_schmidt

# christian_winkler = Fabricate(:christian_winkler)
# meter = Fabricate(:easymeter_60051587)
# register_60051587 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# christian_winkler.add_role(:manager, register_60051587)
# christian_winkler.add_role(:member, register_60051587)
# #christian_winkler.friends << peter_schmidt

# dorothea_wolff = Fabricate(:dorothea_wolff)
# meter = Fabricate(:easymeter_60051566)
# register_60051566 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# dorothea_wolff.add_role(:manager, register_60051566)
# dorothea_wolff.add_role(:member, register_60051566)
# #dorothea_wolff.friends << peter_schmidt

# esra_kwiek = Fabricate(:esra_kwiek)
# meter = Fabricate(:easymeter_60051592)
# register_60051592 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# esra_kwiek.add_role(:manager, register_60051592)
# esra_kwiek.add_role(:member, register_60051592)
# #esra_kwiek.friends << peter_schmidt

# felix_pfeiffer = Fabricate(:felix_pfeiffer)
# meter = Fabricate(:easymeter_60051580)
# register_60051580 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# felix_pfeiffer.add_role(:manager, register_60051580)
# felix_pfeiffer.add_role(:member, register_60051580)
# #felix_pfeiffer.friends << peter_schmidt

# jorg_nasri = Fabricate(:jorg_nasri)
# meter = Fabricate(:easymeter_60051538)
# register_60051538 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# jorg_nasri.add_role(:manager, register_60051538)
# jorg_nasri.add_role(:member, register_60051538)
# #jorg_nasri.friends << peter_schmidt

# ruth_jürgensen = Fabricate(:ruth_juergensen)
# meter = Fabricate(:easymeter_60051590)
# register_60051590 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# ruth_jürgensen.add_role(:manager, register_60051590)
# ruth_jürgensen.add_role(:member, register_60051590)
# #ruth_jürgensen.friends << peter_schmidt

# rafal_jaskolka = Fabricate(:rafal_jaskolka)
# meter = Fabricate(:easymeter_60051588)
# register_60051588 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# rafal_jaskolka.add_role(:manager, register_60051588)
# rafal_jaskolka.add_role(:member, register_60051588)
# #rafal_jaskolka.friends << peter_schmidt

# elisabeth_gritzmann = Fabricate(:elisabeth_gritzmann)
# meter = Fabricate(:easymeter_60051543)
# register_60051543 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# elisabeth_gritzmann.add_role(:manager, register_60051543)
# elisabeth_gritzmann.add_role(:member, register_60051543)
# #elisabeth_gritzmann.friends << peter_schmidt

# matthias_flegel = Fabricate(:matthias_flegel)
# meter = Fabricate(:easymeter_60051582)
# register_60051582 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# matthias_flegel.add_role(:manager, register_60051582)
# matthias_flegel.add_role(:member, register_60051582)
# #matthias_flegel.friends << peter_schmidt

# michael_göbl = Fabricate(:michael_goebl)
# meter = Fabricate(:easymeter_60051539)
# register_60051539 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# michael_göbl.add_role(:manager, register_60051539)
# michael_göbl.add_role(:member, register_60051539)
# #michael_göbl.friends << peter_schmidt

# joaquim_gongolo = Fabricate(:joaquim_gongolo)
# meter = Fabricate(:easymeter_60051545)
# register_60051545 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# joaquim_gongolo.add_role(:manager, register_60051545)
# joaquim_gongolo.add_role(:member, register_60051545)
# #joaquim_gongolo.friends << peter_schmidt

# patrick_haas = Fabricate(:patrick_haas)
# meter = Fabricate(:easymeter_60051614)
# register_60051614 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# patrick_haas.add_role(:manager, register_60051614)
# patrick_haas.add_role(:member, register_60051614)
# #patrick_haas.friends << peter_schmidt

# gundula_herrberg = Fabricate(:gundula_herrberg)
# meter = Fabricate(:easymeter_60051550)
# register_60051550 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# gundula_herrberg.add_role(:manager, register_60051550)
# gundula_herrberg.add_role(:member, register_60051550)
# #gundula_herrberg.friends << peter_schmidt

# dominik_sölch = Fabricate(:dominik_soelch)
# meter = Fabricate(:easymeter_60051573)
# register_60051573 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# dominik_sölch.add_role(:manager, register_60051573)
# dominik_sölch.add_role(:member, register_60051573)
# #dominik_sölch.friends << peter_schmidt

# jessica_rensburg = Fabricate(:jessica_rensburg)
# meter = Fabricate(:easymeter_60051571)
# register_60051571 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# jessica_rensburg.add_role(:manager, register_60051571)
# jessica_rensburg.add_role(:member, register_60051571)
# #jessica_rensburg.friends << peter_schmidt

# ulrich_hafen = Fabricate(:ulrich_hafen)
# meter = Fabricate(:easymeter_60051544)
# register_60051544 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# ulrich_hafen.add_role(:manager, register_60051544)
# ulrich_hafen.add_role(:member, register_60051544)
# #ulrich_hafen.friends << peter_schmidt

# anke_merk = Fabricate(:anke_merk)
# meter = Fabricate(:easymeter_60051594)
# register_60051594 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# anke_merk.add_role(:manager, register_60051594)
# anke_merk.add_role(:member, register_60051594)
# #anke_merk.friends << peter_schmidt

# alex_erdl = Fabricate(:alex_erdl)
# meter = Fabricate(:easymeter_60051583)
# register_60051583 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# alex_erdl.add_role(:manager, register_60051583)
# alex_erdl.add_role(:member, register_60051583)
# #alex_erdl.friends << peter_schmidt

# katrin_frische = Fabricate(:katrin_frische)
# meter = Fabricate(:easymeter_60051604)
# register_60051604 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# katrin_frische.add_role(:manager, register_60051604)
# katrin_frische.add_role(:member, register_60051604)
# #katrin_frische.friends << peter_schmidt

# claudia_krumm = Fabricate(:claudia_krumm)
# meter = Fabricate(:easymeter_60051593)
# register_60051593 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# claudia_krumm.add_role(:manager, register_60051593)
# claudia_krumm.add_role(:member, register_60051593)
# #claudia_krumm.friends << peter_schmidt

# rasim_abazovic = Fabricate(:rasim_abazovic)
# meter = Fabricate(:easymeter_60051613)
# register_60051613 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# rasim_abazovic.add_role(:manager, register_60051613)
# rasim_abazovic.add_role(:member, register_60051613)
# #rasim_abazovic.friends << peter_schmidt

# moritz_feith = Fabricate(:moritz_feith)
# meter = Fabricate(:easymeter_60051611)
# register_60051611 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# moritz_feith.add_role(:manager, register_60051611)
# moritz_feith.add_role(:member, register_60051611)
# #moritz_feith.friends << peter_schmidt

# irmgard_loderer = Fabricate(:irmgard_loderer)
# meter = Fabricate(:easymeter_60051609)
# register_60051609 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# irmgard_loderer.add_role(:manager, register_60051609)
# irmgard_loderer.add_role(:member, register_60051609)
# #irmgard_loderer.friends << peter_schmidt

# eunice_schüler = Fabricate(:eunice_schueler)
# meter = Fabricate(:easymeter_60051554)
# register_60051554 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# eunice_schüler.add_role(:manager, register_60051554)
# eunice_schüler.add_role(:member, register_60051554)
# #eunice_schüler.friends << peter_schmidt

# sara_strödel = Fabricate(:sara_stroedel)
# meter = Fabricate(:easymeter_60051585)
# register_60051585 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# sara_strödel.add_role(:manager, register_60051585)
# sara_strödel.add_role(:member, register_60051585)
# #sara_strödel.friends << peter_schmidt

# hannelore_voigt = Fabricate(:hannelore_voigt)
# meter = Fabricate(:easymeter_60051621)
# register_60051621 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# hannelore_voigt.add_role(:manager, register_60051621)
# hannelore_voigt.add_role(:member, register_60051621)
# #hannelore_voigt.friends << peter_schmidt

# roswitha_weber = Fabricate(:roswitha_weber)
# meter = Fabricate(:easymeter_60051565)
# register_60051565 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# roswitha_weber.add_role(:manager, register_60051565)
# roswitha_weber.add_role(:member, register_60051565)
# #roswitha_weber.friends << peter_schmidt

#TODO: meter number should be 60051565
#alexandra brunner
# alexandra_brunner = Fabricate(:alexandra_brunner)
# meter = Fabricate(:easymeter_60051595)
# register_60051595 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# register_60051595 = Fabricate(:register_60051595)
# alexandra_brunner.add_role(:manager, register_60051595)
# alexandra_brunner.add_role(:member, register_60051595)
#alexandra_brunner.friends << peter_schmidt

# #sww ggmbh
# sww_ggmbh = Fabricate(:sww_ggmbh)
# meter = Fabricate(:easymeter_60051579)
# register_60051579 = meter.input_register
# meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
# sww_ggmbh.add_role(:manager, register_60051579)
# sww_ggmbh.add_role(:member, register_60051579)
# #sww_ggmbh.friends << peter_schmidt

# thirdparty supplied N 42
meter = Fabricate(:easymeter_60051575)
register_60051575 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
peter_schmidt.add_role(:manager, register_60051575)
localpool_forstenried.registers << register_60051575

meter = Fabricate(:easymeter_60009484) #abgrenzung pv
register_60009484 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
peter_schmidt.add_role(:manager, register_60009484)
localpool_forstenried.registers << register_60051575

meter = Fabricate(:easymeter_60138947) #bhkw1
register_60138947 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
peter_schmidt.add_role(:manager, register_60138947)

meter = Fabricate(:easymeter_60138943) #bhkw2
register_60138943 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
peter_schmidt.add_role(:manager, register_60138943)

meter = Fabricate(:easymeter_1338000816) #pv
register_1338000816 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
peter_schmidt.add_role(:manager, register_1338000816)

meter = Fabricate(:easymeter_60009485) #schule
register_60009485 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
peter_schmidt.add_role(:manager, register_60009485)
localpool_forstenried.registers << register_60009485

meter = Fabricate(:easymeter_1338000818) #hst_mitte
register_1338000818 = meter.input_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
peter_schmidt.add_role(:manager, register_1338000818)
localpool_forstenried.registers << register_1338000818

meter = Fabricate(:easymeter_1305004864) #übergabe in out
register_1305004864 = meter.output_register
meter.broker = Fabricate(:discovergy_broker, mode: 'in_out', external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}", resource: meter )
peter_schmidt.add_role(:manager, register_1305004864)
localpool_forstenried.registers << register_60051575

# register_virtual_forstenried_erzeugung = Fabricate(:register_forstenried_erzeugung)
# register_virtual_forstenried_erzeugung.formula_parts << Fabricate(:fp_plus, operand_id: register_60138947.id)
# register_virtual_forstenried_erzeugung.formula_parts << Fabricate(:fp_plus, operand_id: register_60138943.id)
# register_virtual_forstenried_erzeugung.formula_parts << Fabricate(:fp_plus, operand_id: register_1338000816.id)
# peter_schmidt.add_role(:manager, register_virtual_forstenried_erzeugung)
# peter_schmidt.dashboard.registers << register_virtual_forstenried_erzeugung





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
# peter_schmidt.add_role(:manager, register_virtual_forstenried_bezug)
# peter_schmidt.dashboard.registers << register_virtual_forstenried_bezug
#




puts 'send friendships requests for buzzn team'
like_to_friend = Fabricate(:user)
buzzn_team.each do |user|
  FriendshipRequest.create(sender: like_to_friend, receiver: user)
end
