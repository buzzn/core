# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
require 'rubygems' #so it can load gems


my_frontend = Doorkeeper::Application.create(name: 'MyFrontend', redirect_uri: "http://127.0.0.1:4200")

def user_with_metering_point
  metering_point              = Fabricate(:metering_point)
  contracting_party           = Fabricate(:contracting_party)
  user                        = Fabricate(:user)
  user.contracting_party      = contracting_party
  metering_point.users        << user
  user.contracting_party.contracts << metering_point.contracts

  user.add_role :manager, metering_point
  return user, metering_point
end



puts '-- seed development database --'

puts '  organizations'
Fabricate(:electricity_supplier, name: 'buzzn Energy')
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
Fabricate(:metering_point_operator, name: 'buzzn Metering')
Fabricate(:metering_point_operator, name: 'Discovergy')
Fabricate(:metering_point_operator, name: 'Stadtwerke Augsburg')
Fabricate(:metering_point_operator, name: 'Stadtwerke München')
Fabricate(:metering_point_operator, name: 'Andere')


buzzn_team_names = %w[ felix justus danusch thomas martina stefan ole philipp christian ]
buzzn_team = []
buzzn_team_names.each do |user_name|
  puts "  #{user_name}"
  buzzn_team << user = Fabricate(user_name)
  case user_name
  when 'justus'

    @fichtenweg8 = root_mp = mp_z1a = Fabricate(:mp_z1a)
    mp_z1a.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z1a)

    mp_z1b = Fabricate(:mp_z1b)
    user.add_role :manager, mp_z1b
    mp_z1b.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z1b)
    user.contracting_party.contracts << mp_z1b.contracts
    Fabricate(:easymeter_60139082, metering_points: [mp_z1a, mp_z1b])


    mp_z2 = Fabricate(:mp_z2)
    user.add_role :manager, mp_z2
    mp_z2.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z2)
    user.contracting_party.contracts << mp_z2.contracts
    mp_z3 = Fabricate(:mp_z3)
    user.add_role :manager, mp_z3
    mp_z3.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z3)
    user.contracting_party.contracts << mp_z3.contracts
    mp_z4 = Fabricate(:mp_z4)
    user.add_role :manager, mp_z4
    mp_z4.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z4)
    user.contracting_party.contracts << mp_z4.contracts
    mp_z5 = Fabricate(:mp_z5)
    user.add_role :manager, mp_z5
    mp_z5.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z5)
    user.contracting_party.contracts << mp_z5.contracts


    dach_pv_justus = Fabricate(:dach_pv_justus)
    mp_z2.devices << dach_pv_justus
    user.add_role :manager, dach_pv_justus

    bhkw_justus        = Fabricate(:bhkw_justus)
    mp_z4.devices << bhkw_justus
    user.add_role :manager, bhkw_justus

    auto_justus        = Fabricate(:auto_justus)
    mp_z3.devices << auto_justus
    user.add_role :manager, auto_justus

  when 'felix'
    Doorkeeper::AccessToken.create!(:application_id => my_frontend.id, :resource_owner_id => user.id)
    @gocycle       = Fabricate(:gocycle)
    user.add_role :manager, @gocycle
    user.add_role :admin # felix is admin
    root_mp = Fabricate(:mp_urbanstr88)
    root_mp.devices << @gocycle
  when 'christian'
    root_mp = Fabricate(:mp_60138988)
    root_mp.contracts << Fabricate(:mpoc_christian, metering_point: root_mp)
    user.add_role :admin # christian is admin
  when 'philipp'
    root_mp = Fabricate(:mp_60009269)
    root_mp.contracts << Fabricate(:mpoc_philipp, metering_point: root_mp)
  when 'stefan'
    @bhkw_stefan       = Fabricate(:bhkw_stefan)
    @forstenrieder_weg_mp = root_mp = Fabricate(:mp_stefans_bhkw)
    root_mp.contracts << Fabricate(:mpoc_stefan, metering_point: root_mp)
    root_mp.devices << @bhkw_stefan
    user.add_role :manager, @bhkw_stefan
  when 'thomas'
    root_mp = Fabricate(:mp_60176745)
    root_mp.contracts << Fabricate(:mpoc_thomas, metering_point: root_mp)
  else
    root_mp = Fabricate(:metering_point)
  end
  user.add_role :manager, root_mp
  root_mp.users << user

  user.contracting_party.contracts << root_mp.contracts
end

puts 'friendships for buzzn team ...'
buzzn_team.each do |user|
  buzzn_team.each do |friend|
    user.friendships.create(friend: friend) if user != friend
  end
end

uxtest_user = Fabricate(:uxtest_user)



#hof_butenland
jan_gerdes = Fabricate(:jan_gerdes)
mp_hof_butenland_wind   = Fabricate(:mp_hof_butenland_wind)
mp_hof_butenland_wind.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_hof_butenland_wind)
jan_gerdes.add_role :manager, mp_hof_butenland_wind
device = Fabricate(:hof_butenland_wind)
mp_hof_butenland_wind.devices << device
jan_gerdes.add_role :manager, device

mp_hof_butenland_wind.contracts.metering_point_operators.first.contracting_party = jan_gerdes.contracting_party
mp_hof_butenland_wind.contracts.metering_point_operators.first.save


# karin
karin = Fabricate(:karin)
mp_pv_karin = Fabricate(:mp_pv_karin)
mp_pv_karin.contracts << Fabricate(:mpoc_karin, metering_point: mp_pv_karin)
mp_pv_karin.users << karin
karin.add_role :manager, mp_pv_karin
pv_karin = Fabricate(:pv_karin)
karin.add_role :manager, pv_karin
mp_pv_karin.devices << pv_karin
mp_pv_karin.contracts.metering_point_operators.first.contracting_party = karin.contracting_party
mp_pv_karin.contracts.metering_point_operators.first.save

@forstenrieder_weg_mp.users << karin


buzzn_team.each do |buzzn_user|
  karin.friendships.create(friend: buzzn_user) # alle von buzzn sind freund von karin
  buzzn_user.friendships.create(friend: karin)
end



# christian_schuetze
christian_schuetze = Fabricate(:christian_schuetze)
@fichtenweg10 = mp_cs_1 = Fabricate(:mp_cs_1)
christian_schuetze.add_role :manager, mp_cs_1
mp_cs_1.contracts << Fabricate(:mpoc_justus, metering_point: mp_cs_1)
mp_cs_1.users << christian_schuetze
mp_cs_1.contracts.metering_point_operators.first.contracting_party = christian_schuetze.contracting_party
mp_cs_1.contracts.metering_point_operators.first.save



# puts '20 more users with location'
# 20.times do
#   user, location, metering_point = user_with_location
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   puts "  #{user.email}"
# end



puts 'group karin strom'
karins_pv_group = Fabricate(:group_karins_pv_strom, metering_points: [mp_pv_karin])
karin.add_role :manager, karins_pv_group
karins_pv_group.metering_points << User.where(email: 'christian@buzzn.net').first.metering_points.first
karins_pv_group.metering_points << User.where(email: 'philipp@buzzn.net').first.metering_points.first
karins_pv_group.metering_points << User.where(email: 'thomas@buzzn.net').first.metering_points.first
karins_pv_group.create_activity key: 'group.create', owner: karin, recipient: karins_pv_group



puts 'Group Hopf(localpool)'
hans_dieter_hopf  = Fabricate(:hans_dieter_hopf)
manuela_baier     = Fabricate(:manuela_baier)
thomas_hopf       = Fabricate(:thomas_hopf)

mp_60118470 = Fabricate(:mp_60118470)
hans_dieter_hopf.add_role :manager, mp_60118470

mp_60009316 = Fabricate(:mp_60009316)
hans_dieter_hopf.add_role :manager, mp_60009316

mp_60009272 = Fabricate(:mp_60009272)
thomas_hopf.add_role :manager, mp_60009272

mp_60009348 = Fabricate(:mp_60009348)
manuela_baier.add_role :manager, mp_60009348

mp_hans_dieter_hopf = Fabricate(:mp_hans_dieter_hopf)
hans_dieter_hopf.add_role :manager, mp_hans_dieter_hopf
mp_hans_dieter_hopf.formula_parts << Fabricate(:fp_plus, operand_id: mp_60009348.id)
mp_hans_dieter_hopf.formula_parts << Fabricate(:fp_plus, operand_id: mp_60009316.id)

mp_60009272.users         << thomas_hopf
mp_60009348.users         << manuela_baier
mp_60009316.users         << hans_dieter_hopf
mp_hans_dieter_hopf.users << hans_dieter_hopf


group_hopf = Fabricate(:group_hopf, metering_points: [mp_60118470])
group_hopf.metering_points << mp_60009316
group_hopf.metering_points << mp_60009272
group_hopf.metering_points << mp_60009348
group_hopf.metering_points << mp_hans_dieter_hopf



puts 'group hof_butenland'
group_hof_butenland = Fabricate(:group_hof_butenland, metering_points: [mp_hof_butenland_wind])
jan_gerdes.add_role :manager, group_hof_butenland
15.times do
  user, metering_point = user_with_metering_point
  group_hof_butenland.metering_points << metering_point
  puts "  #{user.email}"
end


puts 'group home_of_the_brave'
group_home_of_the_brave = Fabricate(:group_home_of_the_brave, metering_points: [@fichtenweg8])
group_home_of_the_brave.metering_points << @fichtenweg10
justus = User.where(email: 'justus@buzzn.net').first
justus.add_role :manager, group_home_of_the_brave
group_home_of_the_brave.create_activity key: 'group.create', owner: justus, recipient: group_home_of_the_brave



puts 'group wagnis4'
dirk_mittelstaedt = Fabricate(:dirk_mittelstaedt)
mp_60009416 = Fabricate(:mp_60009416)
dirk_mittelstaedt.add_role(:manager, mp_60009416)
mp_60009416.users << dirk_mittelstaedt

manuel_dmoch = Fabricate(:manuel_dmoch)
mp_60009419 = Fabricate(:mp_60009419)
manuel_dmoch.add_role(:manager, mp_60009419)
mp_60009419.users << manuel_dmoch

sibo_ahrens = Fabricate(:sibo_ahrens)
mp_60009415 = Fabricate(:mp_60009415)
sibo_ahrens.add_role(:manager, mp_60009415)
mp_60009415.users << sibo_ahrens

nicolas_sadoni = Fabricate(:nicolas_sadoni)
mp_60009418 = Fabricate(:mp_60009418)
nicolas_sadoni.add_role(:manager, mp_60009418)
mp_60009418.users << nicolas_sadoni

josef_neu = Fabricate(:josef_neu)
mp_60009411 = Fabricate(:mp_60009411)
josef_neu.add_role(:manager, mp_60009411)
mp_60009411.users << josef_neu

elisabeth_christiansen = Fabricate(:elisabeth_christiansen)
mp_60009410 = Fabricate(:mp_60009410)
elisabeth_christiansen.add_role(:manager, mp_60009410)
mp_60009410.users << elisabeth_christiansen

florian_butz = Fabricate(:florian_butz)
mp_60009407 = Fabricate(:mp_60009407)
florian_butz.add_role(:manager, mp_60009407)
mp_60009407.users << florian_butz

ulrike_bez = Fabricate(:ulrike_bez)
mp_60009409 = Fabricate(:mp_60009409)
ulrike_bez.add_role(:manager, mp_60009409)
mp_60009409.users << ulrike_bez

rudolf_hassenstein = Fabricate(:rudolf_hassenstein)
mp_60009435 = Fabricate(:mp_60009435)
rudolf_hassenstein.add_role(:manager, mp_60009435)
mp_60009435.users << rudolf_hassenstein

maria_mueller = Fabricate(:maria_mueller)
mp_60009402 = Fabricate(:mp_60009402)
mp_60009390 = Fabricate(:mp_60009390)
maria_mueller.add_role(:manager, mp_60009402)
maria_mueller.add_role(:manager, mp_60009390)
mp_60009402.users << maria_mueller
mp_60009390.users << maria_mueller

andreas_schlafer = Fabricate(:andreas_schlafer)
mp_60009387 = Fabricate(:mp_60009387)
andreas_schlafer.add_role(:manager, mp_60009387)
mp_60009387.users << andreas_schlafer

luise_woerle = Fabricate(:luise_woerle)
mp_60009438 = Fabricate(:mp_60009438)
luise_woerle.add_role(:manager, mp_60009438)
mp_60009438.users << luise_woerle

peter_waechter = Fabricate(:peter_waechter)
mp_60009440 = Fabricate(:mp_60009440)
peter_waechter.add_role(:manager, mp_60009440)
mp_60009440.users << peter_waechter

sigrid_cycon = Fabricate(:sigrid_cycon)
mp_60009404 = Fabricate(:mp_60009404)
sigrid_cycon.add_role(:manager, mp_60009404)
mp_60009404.users << sigrid_cycon

dietlind_klemm = Fabricate(:dietlind_klemm)
mp_60009405 = Fabricate(:mp_60009405)
dietlind_klemm.add_role(:manager, mp_60009405)
mp_60009405.users << dietlind_klemm

wilhelm_wagner = Fabricate(:wilhelm_wagner)
mp_60009422 = Fabricate(:mp_60009422)
wilhelm_wagner.add_role(:manager, mp_60009422)
mp_60009422.users << wilhelm_wagner

volker_letzner = Fabricate(:volker_letzner)
mp_60009425 = Fabricate(:mp_60009425)
volker_letzner.add_role(:manager, mp_60009425)
mp_60009425.users << volker_letzner

evang_pflege = Fabricate(:evang_pflege)
mp_60009429 = Fabricate(:mp_60009429)
evang_pflege.add_role(:manager, mp_60009429)
mp_60009429.users << evang_pflege

david_stadlmann = Fabricate(:david_stadlmann)
mp_60009393 = Fabricate(:mp_60009393)
david_stadlmann.add_role(:manager, mp_60009393)
mp_60009393.users << david_stadlmann

doris_knaier = Fabricate(:doris_knaier)
mp_60009442 = Fabricate(:mp_60009442)
doris_knaier.add_role(:manager, mp_60009442)
mp_60009442.users << doris_knaier

sabine_dumler = Fabricate(:sabine_dumler)
mp_60009441 = Fabricate(:mp_60009441)
sabine_dumler.add_role(:manager, mp_60009441)
mp_60009441.users << sabine_dumler

mp_60009420 = Fabricate(:mp_60009420)
manuel_dmoch.add_role(:manager, mp_60009420)
mp_60118460 = Fabricate(:mp_60118460)
manuel_dmoch.add_role(:manager, mp_60118460)

group_wagnis4 = Fabricate(:group_wagnis4, metering_points: [mp_60118460])
group_wagnis4.metering_points << mp_60009416
group_wagnis4.metering_points << mp_60009419
group_wagnis4.metering_points << mp_60009415
group_wagnis4.metering_points << mp_60009418
group_wagnis4.metering_points << mp_60009411
group_wagnis4.metering_points << mp_60009410
group_wagnis4.metering_points << mp_60009407
group_wagnis4.metering_points << mp_60009409
group_wagnis4.metering_points << mp_60009435
group_wagnis4.metering_points << mp_60009420
group_wagnis4.metering_points << mp_60009390
group_wagnis4.metering_points << mp_60009402
group_wagnis4.metering_points << mp_60009387
group_wagnis4.metering_points << mp_60009438
group_wagnis4.metering_points << mp_60009440
group_wagnis4.metering_points << mp_60009404
group_wagnis4.metering_points << mp_60009405
group_wagnis4.metering_points << mp_60009422
group_wagnis4.metering_points << mp_60009425
group_wagnis4.metering_points << mp_60009429
group_wagnis4.metering_points << mp_60009393
group_wagnis4.metering_points << mp_60009442
group_wagnis4.metering_points << mp_60009441

manuel_dmoch.add_role(:manager, group_wagnis4)


puts 'group wogeno forstenried'
#Ab hier: Hell & Warm (Forstenried)
markus_becher = Fabricate(:markus_becher)
mp_60051595 = Fabricate(:mp_60051595)
markus_becher.add_role(:manager, mp_60051595)
mp_60051595.users << markus_becher

inge_brack = Fabricate(:inge_brack)
mp_60051547 = Fabricate(:mp_60051547)
inge_brack.add_role(:manager, mp_60051547)
mp_60051547.users << inge_brack

peter_brack = Fabricate(:peter_brack)
mp_60051620 = Fabricate(:mp_60051620)
peter_brack.add_role(:manager, mp_60051620)
mp_60051620.users << peter_brack

annika_brandl = Fabricate(:annika_brandl)
mp_60051602 = Fabricate(:mp_60051602)
annika_brandl.add_role(:manager, mp_60051602)
mp_60051602.users << annika_brandl

gudrun_brandl = Fabricate(:gudrun_brandl)
mp_60051618 = Fabricate(:mp_60051618)
gudrun_brandl.add_role(:manager, mp_60051618)
mp_60051618.users << gudrun_brandl

martin_braeunlich = Fabricate(:martin_braeunlich)
mp_60051557 = Fabricate(:mp_60051557)
martin_braeunlich.add_role(:manager, mp_60051557)
mp_60051557.users << martin_braeunlich

daniel_bruno = Fabricate(:daniel_bruno)
mp_60051596 = Fabricate(:mp_60051596)
daniel_bruno.add_role(:manager, mp_60051596)
mp_60051596.users << daniel_bruno

zubair_butt = Fabricate(:zubair_butt)
mp_60051558 = Fabricate(:mp_60051558)
zubair_butt.add_role(:manager, mp_60051558)
mp_60051558.users << zubair_butt

maria_cerghizan = Fabricate(:maria_cerghizan)
mp_60051551 = Fabricate(:mp_60051551)
maria_cerghizan.add_role(:manager, mp_60051551)
mp_60051551.users << maria_cerghizan

stefan_csizmadia = Fabricate(:stefan_csizmadia)
mp_60051619 = Fabricate(:mp_60051619)
stefan_csizmadia.add_role(:manager, mp_60051619)
mp_60051619.users << stefan_csizmadia

patrick_fierley = Fabricate(:patrick_fierley)
mp_60051556 = Fabricate(:mp_60051556)
patrick_fierley.add_role(:manager, mp_60051556)
mp_60051556.users << patrick_fierley

maria_frank = Fabricate(:maria_frank)
mp_60051617 = Fabricate(:mp_60051617)
maria_frank.add_role(:manager, mp_60051617)
mp_60051617.users << maria_frank

eva_galow = Fabricate(:eva_galow)
mp_60051555 = Fabricate(:mp_60051555)
eva_galow.add_role(:manager, mp_60051555)
mp_60051555.users << eva_galow

christel_guesgen = Fabricate(:christel_guesgen)
mp_60051616 = Fabricate(:mp_60051616)
christel_guesgen.add_role(:manager, mp_60051616)
mp_60051616.users << christel_guesgen

gilda_hencke = Fabricate(:gilda_hencke)
mp_60051615 = Fabricate(:mp_60051615)
gilda_hencke.add_role(:manager, mp_60051615)
mp_60051615.users << gilda_hencke

uwe_hetzer = Fabricate(:uwe_hetzer)
mp_60051546 = Fabricate(:mp_60051546)
uwe_hetzer.add_role(:manager, mp_60051546)
mp_60051546.users << uwe_hetzer

andreas_kapfer = Fabricate(:andreas_kapfer)
mp_60051553 = Fabricate(:mp_60051553)
andreas_kapfer.add_role(:manager, mp_60051553)
mp_60051553.users << andreas_kapfer

renate_koller = Fabricate(:renate_koller)
mp_60051601 = Fabricate(:mp_60051601)
renate_koller.add_role(:manager, mp_60051601)
mp_60051601.users << renate_koller

thekla_lorber = Fabricate(:thekla_lorber)
mp_60051568 = Fabricate(:mp_60051568)
thekla_lorber.add_role(:manager, mp_60051568)
mp_60051568.users << thekla_lorber

ludwig_maassen = Fabricate(:ludwig_maassen)
mp_60051610 = Fabricate(:mp_60051610)
ludwig_maassen.add_role(:manager, mp_60051610)
mp_60051610.users << ludwig_maassen

franz_petschler = Fabricate(:franz_petschler)
mp_60051537 = Fabricate(:mp_60051537)
franz_petschler.add_role(:manager, mp_60051537)
mp_60051537.users << franz_petschler

anna_pfaffel = Fabricate(:anna_pfaffel)
mp_60051564 = Fabricate(:mp_60051564)
anna_pfaffel.add_role(:manager, mp_60051564)
mp_60051564.users << anna_pfaffel

cornelia_roth = Fabricate(:cornelia_roth)
mp_60051572 = Fabricate(:mp_60051572)
cornelia_roth.add_role(:manager, mp_60051572)
mp_60051572.users << cornelia_roth

christiane_voigt = Fabricate(:christiane_voigt)
mp_60051552 = Fabricate(:mp_60051552)
christiane_voigt.add_role(:manager, mp_60051552)
mp_60051552.users << christiane_voigt

claudia_weber = Fabricate(:claudia_weber)
mp_60051567 = Fabricate(:mp_60051567)
claudia_weber.add_role(:manager, mp_60051567)
mp_60051567.users << claudia_weber

sissi_banos = Fabricate(:sissi_banos)
mp_60051586 = Fabricate(:mp_60051586)
sissi_banos.add_role(:manager, mp_60051586)
mp_60051586.users << sissi_banos

laura_häusler = Fabricate(:laura_haeusler)
mp_60051540 = Fabricate(:mp_60051540)
laura_häusler.add_role(:manager, mp_60051540)
mp_60051540.users << laura_häusler

bastian_hentschel = Fabricate(:bastian_hentschel)
mp_60051578 = Fabricate(:mp_60051578)
bastian_hentschel.add_role(:manager, mp_60051578)
mp_60051578.users << bastian_hentschel

dagmar_holland = Fabricate(:dagmar_holland)
mp_60051597 = Fabricate(:mp_60051597)
dagmar_holland.add_role(:manager, mp_60051597)
mp_60051597.users << dagmar_holland

ahmad_majid = Fabricate(:ahmad_majid)
mp_60051541 = Fabricate(:mp_60051541)
ahmad_majid.add_role(:manager, mp_60051541)
mp_60051541.users << ahmad_majid

marinus_meiners = Fabricate(:marinus_meiners)
mp_60051570 = Fabricate(:mp_60051570)
marinus_meiners.add_role(:manager, mp_60051570)
mp_60051570.users << marinus_meiners

wolfgang_pfaffel = Fabricate(:wolfgang_pfaffel)
mp_60051548 = Fabricate(:mp_60051548)
wolfgang_pfaffel.add_role(:manager, mp_60051548)
mp_60051548.users << wolfgang_pfaffel

magali_thomas = Fabricate(:magali_thomas)
mp_60051612 = Fabricate(:mp_60051612)
magali_thomas.add_role(:manager, mp_60051612)
mp_60051612.users << magali_thomas

kathrin_kaisenberg = Fabricate(:kathrin_kaisenberg)
mp_60051549 = Fabricate(:mp_60051549)
kathrin_kaisenberg.add_role(:manager, mp_60051549)
mp_60051549.users << kathrin_kaisenberg

christian_winkler = Fabricate(:christian_winkler)
mp_60051587 = Fabricate(:mp_60051587)
christian_winkler.add_role(:manager, mp_60051587)
mp_60051587.users << christian_winkler

dorothea_wolff = Fabricate(:dorothea_wolff)
mp_60051566 = Fabricate(:mp_60051566)
dorothea_wolff.add_role(:manager, mp_60051566)
mp_60051566.users << dorothea_wolff

esra_kwiek = Fabricate(:esra_kwiek)
mp_60051592 = Fabricate(:mp_60051592)
esra_kwiek.add_role(:manager, mp_60051592)
mp_60051592.users << esra_kwiek

felix_pfeiffer = Fabricate(:felix_pfeiffer)
mp_60051580 = Fabricate(:mp_60051580)
felix_pfeiffer.add_role(:manager, mp_60051580)
mp_60051580.users << felix_pfeiffer

jorg_nasri = Fabricate(:jorg_nasri)
mp_60051538 = Fabricate(:mp_60051538)
jorg_nasri.add_role(:manager, mp_60051538)
mp_60051538.users << jorg_nasri

ruth_jürgensen = Fabricate(:ruth_juergensen)
mp_60051590 = Fabricate(:mp_60051590)
ruth_jürgensen.add_role(:manager, mp_60051590)
mp_60051590.users << ruth_jürgensen

rafal_jaskolka = Fabricate(:rafal_jaskolka)
mp_60051588 = Fabricate(:mp_60051588)
rafal_jaskolka.add_role(:manager, mp_60051588)
mp_60051588.users << rafal_jaskolka

elisabeth_gritzmann = Fabricate(:elisabeth_gritzmann)
mp_60051543 = Fabricate(:mp_60051543)
elisabeth_gritzmann.add_role(:manager, mp_60051543)
mp_60051543.users << elisabeth_gritzmann

matthias_flegel = Fabricate(:matthias_flegel)
mp_60051582 = Fabricate(:mp_60051582)
matthias_flegel.add_role(:manager, mp_60051582)
mp_60051582.users << matthias_flegel

michael_göbl = Fabricate(:michael_goebl)
mp_60051539 = Fabricate(:mp_60051539)
michael_göbl.add_role(:manager, mp_60051539)
mp_60051539.users << michael_göbl

joaquim_gongolo = Fabricate(:joaquim_gongolo)
mp_60051545 = Fabricate(:mp_60051545)
joaquim_gongolo.add_role(:manager, mp_60051545)
mp_60051545.users << joaquim_gongolo

patrick_haas = Fabricate(:patrick_haas)
mp_60051614 = Fabricate(:mp_60051614)
patrick_haas.add_role(:manager, mp_60051614)
mp_60051614.users << patrick_haas

gundula_herrberg = Fabricate(:gundula_herrberg)
mp_60051550 = Fabricate(:mp_60051550)
gundula_herrberg.add_role(:manager, mp_60051550)
mp_60051550.users << gundula_herrberg

dominik_sölch = Fabricate(:dominik_soelch)
mp_60051573 = Fabricate(:mp_60051573)
dominik_sölch.add_role(:manager, mp_60051573)
mp_60051573.users << dominik_sölch

jessica_rensburg = Fabricate(:jessica_rensburg)
mp_60051571 = Fabricate(:mp_60051571)
jessica_rensburg.add_role(:manager, mp_60051571)
mp_60051571.users << jessica_rensburg

ulrich_hafen = Fabricate(:ulrich_hafen)
mp_60051544 = Fabricate(:mp_60051544)
ulrich_hafen.add_role(:manager, mp_60051544)
mp_60051544.users << ulrich_hafen

anke_merk = Fabricate(:anke_merk)
mp_60051594 = Fabricate(:mp_60051594)
anke_merk.add_role(:manager, mp_60051594)
mp_60051594.users << anke_merk

alex_erdl = Fabricate(:alex_erdl)
mp_60051583 = Fabricate(:mp_60051583)
alex_erdl.add_role(:manager, mp_60051583)
mp_60051583.users << alex_erdl

katrin_frische = Fabricate(:katrin_frische)
mp_60051604 = Fabricate(:mp_60051604)
katrin_frische.add_role(:manager, mp_60051604)
mp_60051604.users << katrin_frische

claudia_krumm = Fabricate(:claudia_krumm)
mp_60051593 = Fabricate(:mp_60051593)
claudia_krumm.add_role(:manager, mp_60051593)
mp_60051593.users << claudia_krumm

rasim_abazovic = Fabricate(:rasim_abazovic)
mp_60051613 = Fabricate(:mp_60051613)
rasim_abazovic.add_role(:manager, mp_60051613)
mp_60051613.users << rasim_abazovic

moritz_feith = Fabricate(:moritz_feith)
mp_60051611 = Fabricate(:mp_60051611)
moritz_feith.add_role(:manager, mp_60051611)
mp_60051611.users << moritz_feith

irmgard_loderer = Fabricate(:irmgard_loderer)
mp_60051609 = Fabricate(:mp_60051609)
irmgard_loderer.add_role(:manager, mp_60051609)
mp_60051609.users << irmgard_loderer

eunice_schüler = Fabricate(:eunice_schueler)
mp_60051554 = Fabricate(:mp_60051554)
eunice_schüler.add_role(:manager, mp_60051554)
mp_60051554.users << eunice_schüler

sara_strödel = Fabricate(:sara_stroedel)
mp_60051585 = Fabricate(:mp_60051585)
sara_strödel.add_role(:manager, mp_60051585)
mp_60051585.users << sara_strödel

hannelore_voigt = Fabricate(:hannelore_voigt)
mp_60051621 = Fabricate(:mp_60051621)
hannelore_voigt.add_role(:manager, mp_60051621)
mp_60051621.users << hannelore_voigt

roswitha_weber = Fabricate(:roswitha_weber)
mp_60051565 = Fabricate(:mp_60051565)
roswitha_weber.add_role(:manager, mp_60051565)
mp_60051565.users << roswitha_weber

# #alexandra brunner
# Fabricator :mp_6005195, from: :metering_point do
#   address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
#  name  'N 27'
#  meter          { Fabricate(:easymeter_60051595) }
# end

# #sww ggmbh
# Fabricator :mp_6005195, from: :metering_point do
#   address        { Fabricate(:address, street_name: 'Limmatstraße', street_number: '3', zip: 81476, city: 'München', state: 'Bayern') }
#  name  'N 01'
#  meter          { Fabricate(:easymeter_60051595) }
# end

peter_schmidt = Fabricate(:peter_schmidt)
mp_60009484 = Fabricate(:mp_60009484) #abgrenzung pv
peter_schmidt.add_role(:manager, mp_60009484)
mp_60138947 = Fabricate(:mp_60138947) #bhkw1
peter_schmidt.add_role(:manager, mp_60138947)
mp_60138943 = Fabricate(:mp_60138943) #bhkw2
peter_schmidt.add_role(:manager, mp_60138943)
mp_1338000816 = Fabricate(:mp_1338000816) #pv
peter_schmidt.add_role(:manager, mp_1338000816)
mp_60009485 = Fabricate(:mp_60009485) #schule
peter_schmidt.add_role(:manager, mp_60009485)
mp_1338000818 = Fabricate(:mp_1338000818) #hst_mitte
peter_schmidt.add_role(:manager, mp_1338000818)
mp_1305004864 = Fabricate(:mp_1305004864) #übergabe in
peter_schmidt.add_role(:manager, mp_1305004864)
mp_1305004864_out = Fabricate(:mp_1305004864_out) #übergabe out
peter_schmidt.add_role(:manager, mp_1305004864_out)

group_forstenried = Fabricate(:group_forstenried, metering_points: [mp_60138947, mp_60138943, mp_1338000816])
peter_schmidt.add_role(:manager, group_forstenried)

group_forstenried.metering_points << mp_60051595
group_forstenried.metering_points << mp_60051547
group_forstenried.metering_points << mp_60051620
group_forstenried.metering_points << mp_60051602
group_forstenried.metering_points << mp_60051618
group_forstenried.metering_points << mp_60051557
group_forstenried.metering_points << mp_60051596
group_forstenried.metering_points << mp_60051558
group_forstenried.metering_points << mp_60051551
group_forstenried.metering_points << mp_60051619
group_forstenried.metering_points << mp_60051556
group_forstenried.metering_points << mp_60051617
group_forstenried.metering_points << mp_60051555
group_forstenried.metering_points << mp_60051616
group_forstenried.metering_points << mp_60051615
group_forstenried.metering_points << mp_60051546
group_forstenried.metering_points << mp_60051553
group_forstenried.metering_points << mp_60051601
group_forstenried.metering_points << mp_60051568
group_forstenried.metering_points << mp_60051610
group_forstenried.metering_points << mp_60051537
group_forstenried.metering_points << mp_60051564
group_forstenried.metering_points << mp_60051572
group_forstenried.metering_points << mp_60051552
group_forstenried.metering_points << mp_60051567
group_forstenried.metering_points << mp_60051586
group_forstenried.metering_points << mp_60051540
group_forstenried.metering_points << mp_60051578
group_forstenried.metering_points << mp_60051597
group_forstenried.metering_points << mp_60051541
group_forstenried.metering_points << mp_60051570
group_forstenried.metering_points << mp_60051548
group_forstenried.metering_points << mp_60051612
group_forstenried.metering_points << mp_60051549
group_forstenried.metering_points << mp_60051587
group_forstenried.metering_points << mp_60051566
group_forstenried.metering_points << mp_60051592
group_forstenried.metering_points << mp_60051580
group_forstenried.metering_points << mp_60051538
group_forstenried.metering_points << mp_60051590
group_forstenried.metering_points << mp_60051588
group_forstenried.metering_points << mp_60051543
group_forstenried.metering_points << mp_60051582
group_forstenried.metering_points << mp_60051539
group_forstenried.metering_points << mp_60051545
group_forstenried.metering_points << mp_60051614
group_forstenried.metering_points << mp_60051550
group_forstenried.metering_points << mp_60051573
group_forstenried.metering_points << mp_60051571
group_forstenried.metering_points << mp_60051544
group_forstenried.metering_points << mp_60051594
group_forstenried.metering_points << mp_60051583
group_forstenried.metering_points << mp_60051604
group_forstenried.metering_points << mp_60051593
group_forstenried.metering_points << mp_60051613
group_forstenried.metering_points << mp_60051611
group_forstenried.metering_points << mp_60051609
group_forstenried.metering_points << mp_60051554
group_forstenried.metering_points << mp_60051585
group_forstenried.metering_points << mp_60051621
group_forstenried.metering_points << mp_60051565




puts '5 simple users'
5.times do
  user = Fabricate(:user)
  puts "  #{user.email}"
end


puts 'send friendships requests for buzzn team'
like_to_friend = Fabricate(:user)
buzzn_team.each do |user|
  FriendshipRequest.create(sender: like_to_friend, receiver: user)
end














