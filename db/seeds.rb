# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

def user_with_register
  register = Fabricate(:register)
  user     = Fabricate(:user)
  metering_point.contracts.each do |contract|
    #user.contracting_parties.first.assigned_contracts << contract
  end

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
  user.contracting_parties << Fabricate(:contracting_party)
  case user_name
  when 'justus'
    easymeter_60139082 = Fabricate(:easymeter_60139082)
    easymeter_60139082.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_60139082", resource: easymeter_60139082)
    register_z1a = easymeter_60139082.registers.first
    register_z1b = easymeter_60139082.registers.last
    @fichtenweg8 = root_register = register_z1a
    user.add_role :manager, register_z1a
    user.add_role :manager, register_z1b
    register_z1a.contracts.each do |contract|
      user.contracting_parties.first.assigned_contracts << contract
      contract.save
    end
    register_z1b.contracts.each do |contract|
      user.contracting_parties.first.assigned_contracts << contract
    end
    easymeter_60051599 = Fabricate(:easymeter_60051599)
    easymeter_60051599.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_60051599", resource: easymeter_60051599)
    @register_z2 = easymeter_60051599.registers.first
    user.add_role :manager, @register_z2
    @register_z2.contracts.each do |contract|
      user.contracting_parties.first.assigned_contracts << contract
    end
    easymeter_60051559 = Fabricate(:easymeter_60051559)
    easymeter_60051559.broker = Fabricate(:discovergy_broker, mode: 'in', external_id: "EASYMETER_60051559", resource: easymeter_60051559)
    @register_z3 = easymeter_60051559.registers.first
    user.add_role :manager, @register_z3
    @register_z3.contracts.each do |contract|
      user.contracting_parties.first.assigned_contracts << contract
    end
    easymeter_60051560 = Fabricate(:easymeter_60051560)
    easymeter_60051560.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_60051560", resource: easymeter_60051560)
    @register_z4 = easymeter_60051560.registers.first
    user.add_role :manager, @register_z4
    @register_z4.contracts.each do |contract|
      user.contracting_parties.first.assigned_contracts << contract
    end
    easymeter_60051600 = Fabricate(:easymeter_60051600)
    easymeter_60051600.broker = Fabricate(:discovergy_broker, mode: 'out', external_id: "EASYMETER_60051600", resource: easymeter_60051600)
    @register_z5 = easymeter_60051600.registers.first
    user.add_role :manager, @register_z5
    @register_z5.contracts.each do |contract|
      user.contracting_parties.first.assigned_contracts << contract
    end


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
    contract = Fabricate(:mpoc_christian)
    root_register = contract.register
    meter = root_register.meter
    meter.broker = Fabricate(:discovergy_broker,
      mode: 'in',
      external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}",
      resource: meter,
      provider_login: 'christian@buzzn.net',
      provider_login: 'Roentgen11smartmeter'
    )
    user.add_role :admin # christian is admin
  when 'philipp'
    contract = Fabricate(:mpoc_philipp)
    root_register = contract.register
    meter = root_register.meter
    meter.broker = Fabricate(:discovergy_broker,
      mode: 'in',
      external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}",
      resource: meter,
      provider_login: 'info@philipp-osswald.de',
      provider_login: 'Null8fünfzehn'
    )
  when 'stefan'
    bhkw_stefan       = Fabricate(:bhkw_stefan)
    contract = Fabricate(:mpoc_stefan)
    root_register = contract.register
    root_register.devices << bhkw_stefan
    user.add_role :manager, bhkw_stefan
    meter = root_register.meter
    meter.broker = Fabricate(:discovergy_broker,
      mode: 'in',
      external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}",
      resource: meter,
      provider_login: 'stefan@buzzn.net',
      provider_login: '19200buzzn'
    )
  when 'thomas'
    contract = Fabricate(:mpoc_ferraris_0001_amperix)
    root_register = contract.register
    user.add_role :admin # thomas is admin
  when 'kristian'
    root_register = Fabricate(:input_meter).input_register
    Fabricate(:mpoc_buzzn_metering, register: root_register)
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
# register_hof_butenland_wind.contracts << Fabricate(:mpoc_buzzn_metering, register: register_hof_butenland_wind)
# jan_gerdes.add_role :manager, register_hof_butenland_wind
# device = Fabricate(:hof_butenland_wind)
# register_hof_butenland_wind.devices << device
# jan_gerdes.add_role :manager, device

# register_hof_butenland_wind.contracts.metering_point_operators.first.contracting_party = jan_gerdes.contracting_party
# register_hof_butenland_wind.contracts.metering_point_operators.first.save


# karin
register_pv_karin = Fabricate(:mpoc_karin).register
karin = register_pv_karin.managers.first
meter = register_pv_karin.meter
meter.broker = Fabricate(:discovergy_broker,
  mode: 'in',
  external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}",
  resource: meter,
  provider_login: 'karin.smith@solfux.de',
  provider_login: '19200buzzn'
)

buzzn_team.each do |buzzn_user|
  karin.friendships.create(friend: buzzn_user) # alle von buzzn sind freund von karin
  buzzn_user.friendships.create(friend: karin)
end

#Dieser User wird allen Kommentaren von gelöschten Benutzern zugewiesen
geloeschter_benutzer = Fabricate(:geloeschter_benutzer)



# christian_schuetze
@fichtenweg10 = register_cs_1 = Fabricate(:easymeter_1124001747).input_register



# puts '20 more users with location'
# 20.times do
#   user, location, register = user_with_location
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   puts "  #{user.email}"
# end



puts 'group karin strom'
karins_pv_group = Fabricate(:group_karins_pv_strom, registers: [register_pv_karin])
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


group_hopf = Fabricate(:group_hopf, registers: [register_60009316])
group_hopf.registers << register_60009272
group_hopf.registers << register_60009348
group_hopf.registers << register_hans_dieter_hopf



# puts 'group hof_butenland'
# group_hof_butenland = Fabricate(:group_hof_butenland, registers: [register_hof_butenland_wind])
# jan_gerdes.add_role :manager, group_hof_butenland
# 15.times do
#   user, register = user_with_register
#   group_hof_butenland.registers << register
#   puts "  #{user.email}"
# end


puts 'group home_of_the_brave'
group_home_of_the_brave = Fabricate(:group_home_of_the_brave, registers: [@register_z2, @register_z4])
group_home_of_the_brave.registers << @register_z3
justus = User.where(email: 'justus@buzzn.net').first
justus.add_role :manager, group_home_of_the_brave
#group_home_of_the_brave.create_activity key: 'group.create', owner: justus, recipient: group_home_of_the_brave



puts 'group wagnis4'
dirk_mittelstaedt = Fabricate(:dirk_mittelstaedt)
register_60009416 = Fabricate(:easymeter_60009416).input_register
dirk_mittelstaedt.add_role(:manager, register_60009416)
dirk_mittelstaedt.add_role(:member, register_60009416)

manuel_dmoch = Fabricate(:manuel_dmoch)
register_60009419 = Fabricate(:easymeter_60009419).input_register
manuel_dmoch.add_role(:manager, register_60009419)
manuel_dmoch.add_role(:member, register_60009419)

sibo_ahrens = Fabricate(:sibo_ahrens)
register_60009415 = Fabricate(:easymeter_60009415).input_register
sibo_ahrens.add_role(:manager, register_60009415)
sibo_ahrens.add_role(:member, register_60009415)

nicolas_sadoni = Fabricate(:nicolas_sadoni)
register_60009418 = Fabricate(:easymeter_60009418).input_register
nicolas_sadoni.add_role(:manager, register_60009418)
nicolas_sadoni.add_role(:member, register_60009418)

josef_neu = Fabricate(:josef_neu)
register_60009411 = Fabricate(:easymeter_60009411).input_register
josef_neu.add_role(:manager, register_60009411)
josef_neu.add_role(:member, register_60009411)

elisabeth_christiansen = Fabricate(:elisabeth_christiansen)
register_60009410 = Fabricate(:easymeter_60009410).input_register
elisabeth_christiansen.add_role(:manager, register_60009410)
elisabeth_christiansen.add_role(:member, register_60009410)

florian_butz = Fabricate(:florian_butz)
register_60009407 = Fabricate(:easymeter_60009407).input_register
florian_butz.add_role(:manager, register_60009407)
florian_butz.add_role(:member, register_60009407)

ulrike_bez = Fabricate(:ulrike_bez)
register_60009409 = Fabricate(:easymeter_60009409).input_register
ulrike_bez.add_role(:manager, register_60009409)
ulrike_bez.add_role(:member, register_60009409)

rudolf_hassenstein = Fabricate(:rudolf_hassenstein)
register_60009435 = Fabricate(:easymeter_60009435).input_register
rudolf_hassenstein.add_role(:manager, register_60009435)
rudolf_hassenstein.add_role(:member, register_60009435)

maria_mueller = Fabricate(:maria_mueller)
register_60009402 = Fabricate(:easymeter_60009402).input_register
register_60009390 = Fabricate(:easymeter_60009390).input_register
maria_mueller.add_role(:manager, register_60009402)
maria_mueller.add_role(:manager, register_60009390)
maria_mueller.add_role(:member, register_60009402)
maria_mueller.add_role(:member, register_60009390)

andreas_schlafer = Fabricate(:andreas_schlafer)
register_60009387 = Fabricate(:easymeter_60009387).input_register
andreas_schlafer.add_role(:manager, register_60009387)
andreas_schlafer.add_role(:member, register_60009387)

luise_woerle = Fabricate(:luise_woerle)
register_60009438 = Fabricate(:easymeter_60009438).input_register
luise_woerle.add_role(:manager, register_60009438)
luise_woerle.add_role(:member, register_60009438)

peter_waechter = Fabricate(:peter_waechter)
register_60009440 = Fabricate(:easymeter_60009440).input_register
peter_waechter.add_role(:manager, register_60009440)
peter_waechter.add_role(:member, register_60009440)

sigrid_cycon = Fabricate(:sigrid_cycon)
register_60009404 = Fabricate(:easymeter_60009404).input_register
sigrid_cycon.add_role(:manager, register_60009404)
sigrid_cycon.add_role(:member, register_60009404)

dietlind_klemm = Fabricate(:dietlind_klemm)
register_60009405 = Fabricate(:easymeter_60009405).input_register
dietlind_klemm.add_role(:manager, register_60009405)
dietlind_klemm.add_role(:member, register_60009405)

wilhelm_wagner = Fabricate(:wilhelm_wagner)
register_60009422 = Fabricate(:easymeter_60009422).input_register
wilhelm_wagner.add_role(:manager, register_60009422)
wilhelm_wagner.add_role(:member, register_60009422)

volker_letzner = Fabricate(:volker_letzner)
register_60009425 = Fabricate(:easymeter_60009425).input_register
volker_letzner.add_role(:manager, register_60009425)
volker_letzner.add_role(:member, register_60009425)

evang_pflege = Fabricate(:evang_pflege)
register_60009429 = Fabricate(:easymeter_60009429).input_register
evang_pflege.add_role(:manager, register_60009429)
evang_pflege.add_role(:member, register_60009429)

david_stadlmann = Fabricate(:david_stadlmann)
register_60009393 = Fabricate(:easymeter_60009393).input_register
david_stadlmann.add_role(:manager, register_60009393)
david_stadlmann.add_role(:member, register_60009393)

doris_knaier = Fabricate(:doris_knaier)
register_60009442 = Fabricate(:easymeter_60009442).input_register
doris_knaier.add_role(:manager, register_60009442)
doris_knaier.add_role(:member, register_60009442)

sabine_dumler = Fabricate(:sabine_dumler)
register_60009441 = Fabricate(:easymeter_60009441).input_register
sabine_dumler.add_role(:manager, register_60009441)
sabine_dumler.add_role(:member, register_60009441)

register_60009420 = Fabricate(:easymeter_60009420).input_register
manuel_dmoch.add_role(:manager, register_60009420)
register_60118460 = Fabricate(:easymeter_60118460).output_register
manuel_dmoch.add_role(:manager, register_60118460)

group_wagnis4 = Fabricate(:group_wagnis4, registers: [register_60118460])
group_wagnis4.registers << register_60009416
group_wagnis4.registers << register_60009419
group_wagnis4.registers << register_60009415
group_wagnis4.registers << register_60009418
group_wagnis4.registers << register_60009411
group_wagnis4.registers << register_60009410
group_wagnis4.registers << register_60009407
group_wagnis4.registers << register_60009409
group_wagnis4.registers << register_60009435
group_wagnis4.registers << register_60009420
group_wagnis4.registers << register_60009390
group_wagnis4.registers << register_60009402
group_wagnis4.registers << register_60009387
group_wagnis4.registers << register_60009438
group_wagnis4.registers << register_60009440
group_wagnis4.registers << register_60009404
group_wagnis4.registers << register_60009405
group_wagnis4.registers << register_60009422
group_wagnis4.registers << register_60009425
group_wagnis4.registers << register_60009429
group_wagnis4.registers << register_60009393
group_wagnis4.registers << register_60009442
group_wagnis4.registers << register_60009441

manuel_dmoch.add_role(:manager, group_wagnis4)


# puts 'group wogeno forstenried'
# #Ab hier: Hell & Warm (Forstenried)
# peter_schmidt = Fabricate(:peter_schmidt)


# markus_becher = Fabricate(:markus_becher)
# register_60051595 = Fabricate(:register_60051595)
# markus_becher.add_role(:manager, register_60051595)
# markus_becher.add_role(:member, register_60051595)
# #markus_becher.friends << peter_schmidt

# inge_brack = Fabricate(:inge_brack)
# register_60051547 = Fabricate(:register_60051547)
# inge_brack.add_role(:manager, register_60051547)
# inge_brack.add_role(:member, register_60051547)
# #inge_brack.friends << peter_schmidt

# peter_brack = Fabricate(:peter_brack)
# register_60051620 = Fabricate(:register_60051620)
# peter_brack.add_role(:manager, register_60051620)
# peter_brack.add_role(:member, register_60051620)
# #peter_brack.friends << peter_schmidt

# annika_brandl = Fabricate(:annika_brandl)
# register_60051602 = Fabricate(:register_60051602)
# annika_brandl.add_role(:manager, register_60051602)
# annika_brandl.add_role(:member, register_60051602)
# #annika_brandl.friends << peter_schmidt

# gudrun_brandl = Fabricate(:gudrun_brandl)
# register_60051618 = Fabricate(:register_60051618)
# gudrun_brandl.add_role(:manager, register_60051618)
# gudrun_brandl.add_role(:member, register_60051618)
# #gudrun_brandl.friends << peter_schmidt

# martin_braeunlich = Fabricate(:martin_braeunlich)
# register_60051557 = Fabricate(:register_60051557)
# martin_braeunlich.add_role(:manager, register_60051557)
# martin_braeunlich.add_role(:member, register_60051557)
# #martin_braeunlich.friends << peter_schmidt

# daniel_bruno = Fabricate(:daniel_bruno)
# register_60051596 = Fabricate(:register_60051596)
# daniel_bruno.add_role(:manager, register_60051596)
# daniel_bruno.add_role(:member, register_60051596)
# #daniel_bruno.friends << peter_schmidt

# zubair_butt = Fabricate(:zubair_butt)
# register_60051558 = Fabricate(:register_60051558)
# zubair_butt.add_role(:manager, register_60051558)
# zubair_butt.add_role(:member, register_60051558)
# #zubair_butt.friends << peter_schmidt

# maria_cerghizan = Fabricate(:maria_cerghizan)
# register_60051551 = Fabricate(:register_60051551)
# maria_cerghizan.add_role(:manager, register_60051551)
# maria_cerghizan.add_role(:member, register_60051551)
# #maria_cerghizan.friends << peter_schmidt

# stefan_csizmadia = Fabricate(:stefan_csizmadia)
# register_60051619 = Fabricate(:register_60051619)
# stefan_csizmadia.add_role(:manager, register_60051619)
# stefan_csizmadia.add_role(:member, register_60051619)
# #stefan_csizmadia.friends << peter_schmidt

# patrick_fierley = Fabricate(:patrick_fierley)
# register_60051556 = Fabricate(:register_60051556)
# patrick_fierley.add_role(:manager, register_60051556)
# patrick_fierley.add_role(:member, register_60051556)
# #patrick_fierley.friends << peter_schmidt

# maria_frank = Fabricate(:maria_frank)
# register_60051617 = Fabricate(:register_60051617)
# maria_frank.add_role(:manager, register_60051617)
# maria_frank.add_role(:member, register_60051617)
# #maria_frank.friends << peter_schmidt

# eva_galow = Fabricate(:eva_galow)
# register_60051555 = Fabricate(:register_60051555)
# eva_galow.add_role(:manager, register_60051555)
# eva_galow.add_role(:member, register_60051555)
# #eva_galow.friends << peter_schmidt

# christel_guesgen = Fabricate(:christel_guesgen)
# register_60051616 = Fabricate(:register_60051616)
# christel_guesgen.add_role(:manager, register_60051616)
# christel_guesgen.add_role(:member, register_60051616)
# #christel_guesgen.friends << peter_schmidt

# gilda_hencke = Fabricate(:gilda_hencke)
# register_60051615 = Fabricate(:register_60051615)
# gilda_hencke.add_role(:manager, register_60051615)
# gilda_hencke.add_role(:member, register_60051615)
# #gilda_hencke.friends << peter_schmidt

# uwe_hetzer = Fabricate(:uwe_hetzer)
# register_60051546 = Fabricate(:register_60051546)
# uwe_hetzer.add_role(:manager, register_60051546)
# uwe_hetzer.add_role(:member, register_60051546)
# #uwe_hetzer.friends << peter_schmidt

# andreas_kapfer = Fabricate(:andreas_kapfer)
# register_60051553 = Fabricate(:register_60051553)
# andreas_kapfer.add_role(:manager, register_60051553)
# andreas_kapfer.add_role(:member, register_60051553)
# #andreas_kapfer.friends << peter_schmidt

# renate_koller = Fabricate(:renate_koller)
# register_60051601 = Fabricate(:register_60051601)
# renate_koller.add_role(:manager, register_60051601)
# renate_koller.add_role(:member, register_60051601)
# #renate_koller.friends << peter_schmidt

# thekla_lorber = Fabricate(:thekla_lorber)
# register_60051568 = Fabricate(:register_60051568)
# thekla_lorber.add_role(:manager, register_60051568)
# thekla_lorber.add_role(:member, register_60051568)
# #thekla_lorber.friends << peter_schmidt

# ludwig_maassen = Fabricate(:ludwig_maassen)
# register_60051610 = Fabricate(:register_60051610)
# ludwig_maassen.add_role(:manager, register_60051610)
# ludwig_maassen.add_role(:member, register_60051610)
# #ludwig_maassen.friends << peter_schmidt

# franz_petschler = Fabricate(:franz_petschler)
# register_60051537 = Fabricate(:register_60051537)
# franz_petschler.add_role(:manager, register_60051537)
# franz_petschler.add_role(:member, register_60051537)
# #franz_petschler.friends << peter_schmidt

# anna_pfaffel = Fabricate(:anna_pfaffel)
# register_60051564 = Fabricate(:register_60051564)
# anna_pfaffel.add_role(:manager, register_60051564)
# anna_pfaffel.add_role(:member, register_60051564)
# #anna_pfaffel.friends << peter_schmidt

# cornelia_roth = Fabricate(:cornelia_roth)
# register_60051572 = Fabricate(:register_60051572)
# cornelia_roth.add_role(:manager, register_60051572)
# cornelia_roth.add_role(:member, register_60051572)
# #cornelia_roth.friends << peter_schmidt

# christiane_voigt = Fabricate(:christiane_voigt)
# register_60051552 = Fabricate(:register_60051552)
# christiane_voigt.add_role(:manager, register_60051552)
# christiane_voigt.add_role(:member, register_60051552)
# #christiane_voigt.friends << peter_schmidt

# claudia_weber = Fabricate(:claudia_weber)
# register_60051567 = Fabricate(:register_60051567)
# claudia_weber.add_role(:manager, register_60051567)
# claudia_weber.add_role(:member, register_60051567)
# #claudia_weber.friends << peter_schmidt

# sissi_banos = Fabricate(:sissi_banos)
# register_60051586 = Fabricate(:register_60051586)
# sissi_banos.add_role(:manager, register_60051586)
# sissi_banos.add_role(:member, register_60051586)
# #sissi_banos.friends << peter_schmidt

# laura_häusler = Fabricate(:laura_haeusler)
# register_60051540 = Fabricate(:register_60051540)
# laura_häusler.add_role(:manager, register_60051540)
# laura_häusler.add_role(:member, register_60051540)
# #laura_häusler.friends << peter_schmidt

# bastian_hentschel = Fabricate(:bastian_hentschel)
# register_60051578 = Fabricate(:register_60051578)
# bastian_hentschel.add_role(:manager, register_60051578)
# bastian_hentschel.add_role(:member, register_60051578)
# #bastian_hentschel.friends << peter_schmidt

# dagmar_holland = Fabricate(:dagmar_holland)
# register_60051597 = Fabricate(:register_60051597)
# dagmar_holland.add_role(:manager, register_60051597)
# dagmar_holland.add_role(:member, register_60051597)
# #dagmar_holland.friends << peter_schmidt

# ahmad_majid = Fabricate(:ahmad_majid)
# register_60051541 = Fabricate(:register_60051541)
# ahmad_majid.add_role(:manager, register_60051541)
# ahmad_majid.add_role(:member, register_60051541)
# #ahmad_majid.friends << peter_schmidt

# marinus_meiners = Fabricate(:marinus_meiners)
# register_60051570 = Fabricate(:register_60051570)
# marinus_meiners.add_role(:manager, register_60051570)
# marinus_meiners.add_role(:member, register_60051570)
# #marinus_meiners.friends << peter_schmidt

# wolfgang_pfaffel = Fabricate(:wolfgang_pfaffel)
# register_60051548 = Fabricate(:register_60051548)
# wolfgang_pfaffel.add_role(:manager, register_60051548)
# wolfgang_pfaffel.add_role(:member, register_60051548)
# #wolfgang_pfaffel.friends << peter_schmidt

# magali_thomas = Fabricate(:magali_thomas)
# register_60051612 = Fabricate(:register_60051612)
# magali_thomas.add_role(:manager, register_60051612)
# magali_thomas.add_role(:member, register_60051612)
# #magali_thomas.friends << peter_schmidt

# kathrin_kaisenberg = Fabricate(:kathrin_kaisenberg)
# register_60051549 = Fabricate(:register_60051549)
# kathrin_kaisenberg.add_role(:manager, register_60051549)
# kathrin_kaisenberg.add_role(:member, register_60051549)
# #kathrin_kaisenberg.friends << peter_schmidt

# christian_winkler = Fabricate(:christian_winkler)
# register_60051587 = Fabricate(:register_60051587)
# christian_winkler.add_role(:manager, register_60051587)
# christian_winkler.add_role(:member, register_60051587)
# #christian_winkler.friends << peter_schmidt

# dorothea_wolff = Fabricate(:dorothea_wolff)
# register_60051566 = Fabricate(:register_60051566)
# dorothea_wolff.add_role(:manager, register_60051566)
# dorothea_wolff.add_role(:member, register_60051566)
# #dorothea_wolff.friends << peter_schmidt

# esra_kwiek = Fabricate(:esra_kwiek)
# register_60051592 = Fabricate(:register_60051592)
# esra_kwiek.add_role(:manager, register_60051592)
# esra_kwiek.add_role(:member, register_60051592)
# #esra_kwiek.friends << peter_schmidt

# felix_pfeiffer = Fabricate(:felix_pfeiffer)
# register_60051580 = Fabricate(:register_60051580)
# felix_pfeiffer.add_role(:manager, register_60051580)
# felix_pfeiffer.add_role(:member, register_60051580)
# #felix_pfeiffer.friends << peter_schmidt

# jorg_nasri = Fabricate(:jorg_nasri)
# register_60051538 = Fabricate(:register_60051538)
# jorg_nasri.add_role(:manager, register_60051538)
# jorg_nasri.add_role(:member, register_60051538)
# #jorg_nasri.friends << peter_schmidt

# ruth_jürgensen = Fabricate(:ruth_juergensen)
# register_60051590 = Fabricate(:register_60051590)
# ruth_jürgensen.add_role(:manager, register_60051590)
# ruth_jürgensen.add_role(:member, register_60051590)
# #ruth_jürgensen.friends << peter_schmidt

# rafal_jaskolka = Fabricate(:rafal_jaskolka)
# register_60051588 = Fabricate(:register_60051588)
# rafal_jaskolka.add_role(:manager, register_60051588)
# rafal_jaskolka.add_role(:member, register_60051588)
# #rafal_jaskolka.friends << peter_schmidt

# elisabeth_gritzmann = Fabricate(:elisabeth_gritzmann)
# register_60051543 = Fabricate(:register_60051543)
# elisabeth_gritzmann.add_role(:manager, register_60051543)
# elisabeth_gritzmann.add_role(:member, register_60051543)
# #elisabeth_gritzmann.friends << peter_schmidt

# matthias_flegel = Fabricate(:matthias_flegel)
# register_60051582 = Fabricate(:register_60051582)
# matthias_flegel.add_role(:manager, register_60051582)
# matthias_flegel.add_role(:member, register_60051582)
# #matthias_flegel.friends << peter_schmidt

# michael_göbl = Fabricate(:michael_goebl)
# register_60051539 = Fabricate(:register_60051539)
# michael_göbl.add_role(:manager, register_60051539)
# michael_göbl.add_role(:member, register_60051539)
# #michael_göbl.friends << peter_schmidt

# joaquim_gongolo = Fabricate(:joaquim_gongolo)
# register_60051545 = Fabricate(:register_60051545)
# joaquim_gongolo.add_role(:manager, register_60051545)
# joaquim_gongolo.add_role(:member, register_60051545)
# #joaquim_gongolo.friends << peter_schmidt

# patrick_haas = Fabricate(:patrick_haas)
# register_60051614 = Fabricate(:register_60051614)
# patrick_haas.add_role(:manager, register_60051614)
# patrick_haas.add_role(:member, register_60051614)
# #patrick_haas.friends << peter_schmidt

# gundula_herrberg = Fabricate(:gundula_herrberg)
# register_60051550 = Fabricate(:register_60051550)
# gundula_herrberg.add_role(:manager, register_60051550)
# gundula_herrberg.add_role(:member, register_60051550)
# #gundula_herrberg.friends << peter_schmidt

# dominik_sölch = Fabricate(:dominik_soelch)
# register_60051573 = Fabricate(:register_60051573)
# dominik_sölch.add_role(:manager, register_60051573)
# dominik_sölch.add_role(:member, register_60051573)
# #dominik_sölch.friends << peter_schmidt

# jessica_rensburg = Fabricate(:jessica_rensburg)
# register_60051571 = Fabricate(:register_60051571)
# jessica_rensburg.add_role(:manager, register_60051571)
# jessica_rensburg.add_role(:member, register_60051571)
# #jessica_rensburg.friends << peter_schmidt

# ulrich_hafen = Fabricate(:ulrich_hafen)
# register_60051544 = Fabricate(:register_60051544)
# ulrich_hafen.add_role(:manager, register_60051544)
# ulrich_hafen.add_role(:member, register_60051544)
# #ulrich_hafen.friends << peter_schmidt

# anke_merk = Fabricate(:anke_merk)
# register_60051594 = Fabricate(:register_60051594)
# anke_merk.add_role(:manager, register_60051594)
# anke_merk.add_role(:member, register_60051594)
# #anke_merk.friends << peter_schmidt

# alex_erdl = Fabricate(:alex_erdl)
# register_60051583 = Fabricate(:register_60051583)
# alex_erdl.add_role(:manager, register_60051583)
# alex_erdl.add_role(:member, register_60051583)
# #alex_erdl.friends << peter_schmidt

# katrin_frische = Fabricate(:katrin_frische)
# register_60051604 = Fabricate(:register_60051604)
# katrin_frische.add_role(:manager, register_60051604)
# katrin_frische.add_role(:member, register_60051604)
# #katrin_frische.friends << peter_schmidt

# claudia_krumm = Fabricate(:claudia_krumm)
# register_60051593 = Fabricate(:register_60051593)
# claudia_krumm.add_role(:member, register_60051593)
# #claudia_krumm.friends << peter_schmidt

# rasim_abazovic = Fabricate(:rasim_abazovic)
# register_60051613 = Fabricate(:register_60051613)
# rasim_abazovic.add_role(:manager, register_60051613)
# rasim_abazovic.add_role(:member, register_60051613)
# #rasim_abazovic.friends << peter_schmidt

# moritz_feith = Fabricate(:moritz_feith)
# register_60051611 = Fabricate(:register_60051611)
# moritz_feith.add_role(:manager, register_60051611)
# moritz_feith.add_role(:member, register_60051611)
# #moritz_feith.friends << peter_schmidt

# irmgard_loderer = Fabricate(:irmgard_loderer)
# register_60051609 = Fabricate(:register_60051609)
# irmgard_loderer.add_role(:manager, register_60051609)
# irmgard_loderer.add_role(:member, register_60051609)
# #irmgard_loderer.friends << peter_schmidt

# eunice_schüler = Fabricate(:eunice_schueler)
# register_60051554 = Fabricate(:register_60051554)
# eunice_schüler.add_role(:manager, register_60051554)
# eunice_schüler.add_role(:member, register_60051554)
# #eunice_schüler.friends << peter_schmidt

# sara_strödel = Fabricate(:sara_stroedel)
# register_60051585 = Fabricate(:register_60051585)
# sara_strödel.add_role(:manager, register_60051585)
# sara_strödel.add_role(:member, register_60051585)
# #sara_strödel.friends << peter_schmidt

# hannelore_voigt = Fabricate(:hannelore_voigt)
# register_60051621 = Fabricate(:register_60051621)
# hannelore_voigt.add_role(:manager, register_60051621)
# hannelore_voigt.add_role(:member, register_60051621)
# #hannelore_voigt.friends << peter_schmidt

# roswitha_weber = Fabricate(:roswitha_weber)
# register_60051565 = Fabricate(:register_60051565)
# roswitha_weber.add_role(:manager, register_60051565)
# roswitha_weber.add_role(:member, register_60051565)
# #roswitha_weber.friends << peter_schmidt

# #alexandra brunner
# Fabricator :register_6005195, from: :register do
#   address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
#  name  'N 27'
#  meter          { Fabricate(:easymeter_60051595) }
# end

# #sww ggmbh
# Fabricator :register_6005195, from: :register do
#   address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
#  name  'N 01'
#  meter          { Fabricate(:easymeter_60051595) }
# end

#
# register_60009484 = Fabricate(:register_60009484) #abgrenzung pv
# peter_schmidt.add_role(:manager, register_60009484)
# register_60138947 = Fabricate(:register_60138947) #bhkw1
# peter_schmidt.add_role(:manager, register_60138947)
# register_60138943 = Fabricate(:register_60138943) #bhkw2
# peter_schmidt.add_role(:manager, register_60138943)
# register_1338000816 = Fabricate(:register_1338000816) #pv
# peter_schmidt.add_role(:manager, register_1338000816)
# register_60009485 = Fabricate(:register_60009485) #schule
# peter_schmidt.add_role(:manager, register_60009485)
# register_1338000818 = Fabricate(:register_1338000818) #hst_mitte
# peter_schmidt.add_role(:manager, register_1338000818)
# register_1305004864 = Fabricate(:register_1305004864) #übergabe in
# peter_schmidt.add_role(:manager, register_1305004864)
# register_1305004864_out = Fabricate(:register_1305004864_out) #übergabe out
# peter_schmidt.add_role(:manager, register_1305004864_out)
#
# register_virtual_forstenried_erzeugung = Fabricate(:register_forstenried_erzeugung)
# register_virtual_forstenried_erzeugung.formula_parts << Fabricate(:fp_plus, operand_id: register_60138947.id)
# register_virtual_forstenried_erzeugung.formula_parts << Fabricate(:fp_plus, operand_id: register_60138943.id)
# register_virtual_forstenried_erzeugung.formula_parts << Fabricate(:fp_plus, operand_id: register_1338000816.id)
# peter_schmidt.add_role(:manager, register_virtual_forstenried_erzeugung)
# peter_schmidt.dashboard.registers << register_virtual_forstenried_erzeugung
#
# group_forstenried = Fabricate(:group_forstenried, registers: [register_60138947, register_60138943, register_1338000816])
# peter_schmidt.add_role(:manager, group_forstenried)
#
# group_forstenried.registers << register_60051595
# group_forstenried.registers << register_60051547
# group_forstenried.registers << register_60051620
# group_forstenried.registers << register_60051602
# group_forstenried.registers << register_60051618
# group_forstenried.registers << register_60051557
# group_forstenried.registers << register_60051596
# group_forstenried.registers << register_60051558
# group_forstenried.registers << register_60051551
# group_forstenried.registers << register_60051619
# group_forstenried.registers << register_60051556
# group_forstenried.registers << register_60051617
# group_forstenried.registers << register_60051555
# group_forstenried.registers << register_60051616
# group_forstenried.registers << register_60051615
# group_forstenried.registers << register_60051546
# group_forstenried.registers << register_60051553
# group_forstenried.registers << register_60051601
# group_forstenried.registers << register_60051568
# group_forstenried.registers << register_60051610
# group_forstenried.registers << register_60051537
# group_forstenried.registers << register_60051564
# group_forstenried.registers << register_60051572
# group_forstenried.registers << register_60051552
# group_forstenried.registers << register_60051567
# group_forstenried.registers << register_60051586
# group_forstenried.registers << register_60051540
# group_forstenried.registers << register_60051578
# group_forstenried.registers << register_60051597
# group_forstenried.registers << register_60051541
# group_forstenried.registers << register_60051570
# group_forstenried.registers << register_60051548
# group_forstenried.registers << register_60051612
# group_forstenried.registers << register_60051549
# group_forstenried.registers << register_60051587
# group_forstenried.registers << register_60051566
# group_forstenried.registers << register_60051592
# group_forstenried.registers << register_60051580
# group_forstenried.registers << register_60051538
# group_forstenried.registers << register_60051590
# group_forstenried.registers << register_60051588
# group_forstenried.registers << register_60051543
# group_forstenried.registers << register_60051582
# group_forstenried.registers << register_60051539
# group_forstenried.registers << register_60051545
# group_forstenried.registers << register_60051614
# group_forstenried.registers << register_60051550
# group_forstenried.registers << register_60051573
# group_forstenried.registers << register_60051571
# group_forstenried.registers << register_60051544
# group_forstenried.registers << register_60051594
# group_forstenried.registers << register_60051583
# group_forstenried.registers << register_60051604
# group_forstenried.registers << register_60051593
# group_forstenried.registers << register_60051613
# group_forstenried.registers << register_60051611
# group_forstenried.registers << register_60051609
# group_forstenried.registers << register_60051554
# group_forstenried.registers << register_60051585
# group_forstenried.registers << register_60051621
# group_forstenried.registers << register_60051565
# group_forstenried.registers << register_1338000818
# group_forstenried.registers << register_60009485
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
