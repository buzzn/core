# encoding: utf-8

Fabricator :user do
  email             { FFaker::Internet.email }
  password          '12345678'
  profile           { Fabricate(:profile) }
  after_create { |user | user.confirm! }
end


Fabricator :felix, from: :user do
  email               'felix@buzzn.net'
  profile             { Fabricate(:profile_felix) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :justus, from: :user do
  email       'justus@buzzn.net'
  profile     { Fabricate(:profile_justus) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :danusch, from: :user do
  email       'danusch@buzzn.net'
  profile     { Fabricate(:profile_danusch) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :thomas, from: :user do
  email       'thomas@buzzn.net'
  profile     { Fabricate(:profile_thomas) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :martina, from: :user do
  email       'martina@buzzn.net'
  profile     { Fabricate(:profile_martina) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :stefan, from: :user do
  email       'stefan@buzzn.net'
  profile     { Fabricate(:profile_stefan) }
  contracting_party   { Fabricate(:contracting_party) }
end
Fabricator :karin, from: :user do
  email       'karin.smith@solfux.de'
  profile     { Fabricate(:profile_karin) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :ole, from: :user do
  email       'ole@buzzn.net'
  profile     { Fabricate(:profile_ole) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :philipp, from: :user do
  email       'philipp@buzzn.net'
  profile     { Fabricate(:profile_philipp) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :christian, from: :user do
  email       'christian@buzzn.net'
  profile     { Fabricate(:profile_christian) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :jan_gerdes, from: :user do
  email     'jangerdes@stiftung-fuer-tierschutz.de'
  profile   { Fabricate(:profile_jangerdes) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :christian_schuetze, from: :user do
  email     'christian@schuetze.de'
  profile   { Fabricate(:profile_christian_schuetze) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :hans_dieter_hopf, from: :user do
  email               'hans.dieter.hopf@gmail.de'
  profile             { Fabricate(:profile_hans_dieter_hopf) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :thomas_hopf, from: :user do
  email               'thomas.hopf@gmail.de'
  profile             { Fabricate(:profile_thomas_hopf) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :manuela_baier, from: :user do
  email               'manuela.baier@gmail.de'
  profile             { Fabricate(:profile_manuela_baier) }
  contracting_party   { Fabricate(:contracting_party) }
end




Fabricator :dirk_mittelstaedt, from: :user do
  email               'dirk.mittelstaedt@t-online.de'
  profile             { Fabricate(:profile_dirk_mittelstaedt) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :manuel_dmoch, from: :user do
  email               'manuel.dmoch@gmail.com'
  profile             { Fabricate(:profile_manuel_dmoch) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :sibo_ahrens, from: :user do
  email               'sibo_ahrens@yahoo.de'
  profile             { Fabricate(:profile_sibo_ahrens) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :nicolas_sadoni, from: :user do
  email               'nicolas.sadoni@gmx.de'
  profile             { Fabricate(:profile_nicolas_sadoni) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :josef_neu, from: :user do
  email               'burger.neu@web.de'
  profile             { Fabricate(:profile_josef_neu) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :elisabeth_christiansen, from: :user do
  email               'elisa.christiansen@gmx.de'
  profile             { Fabricate(:profile_elisabeth_christiansen) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :florian_butz, from: :user do
  email               'flob@gmx.net'
  profile             { Fabricate(:profile_florian_butz) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :ulrike_bez, from: :user do
  email               'ulrike@bezmedien.com'
  profile             { Fabricate(:profile_ulrike_bez) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :rudolf_hassenstein, from: :user do
  email               'ruhn@arcor.de'
  profile             { Fabricate(:profile_rudolf_hassenstein) }
  contracting_party   { Fabricate(:contracting_party) }
end



Fabricator :andreas_schlafer, from: :user do
  email               'andreas.schlafer@gmx.de'
  profile             { Fabricate(:profile_andreas_schlafer) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :luise_woerle, from: :user do
  email               'luise.woerle@t-online.de'
  profile             { Fabricate(:profile_luise_woerle) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :peter_waechter, from: :user do
  email               'info.peter.waechter@t-online.de'
  profile             { Fabricate(:profile_peter_waechter) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :sigrid_cycon, from: :user do
  email               'cycon.sigrid@t-online.de'
  profile             { Fabricate(:profile_sigrid_cycon) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :dietlind_klemm, from: :user do
  email               'dietlind.klemm@gmx.de'
  profile             { Fabricate(:profile_dietlind_klemm) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :wilhelm_wagner, from: :user do
  email               'bcw15@t-online.de'
  profile             { Fabricate(:profile_wilhelm_wagner) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :volker_letzner, from: :user do
  email               'vletzner@web.de'
  profile             { Fabricate(:profile_volker_letzner) }
  contracting_party   { Fabricate(:contracting_party) }
end

#maria_mueller -> Kiosk
Fabricator :maria_mueller, from: :user do
  email               'mar_s1@gmx.de'
  profile             { Fabricate(:profile_maria_mueller) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :evang_pflege, from: :user do
  email               'email@ev-pflegedienst.de'
  profile             { Fabricate(:profile_evang_pflege) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :david_stadlmann, from: :user do
  email               'david.stadlmann@divad.de'
  profile             { Fabricate(:profile_david_stadlmann) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :doris_knaier, from: :user do
  email               'info@dorisknaier.de'
  profile             { Fabricate(:profile_doris_knaier) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :sabine_dumler, from: :user do
  email               'sabine.dumler@googlemail.com'
  profile             { Fabricate(:profile_sabine_dumler) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :uxtest_user, from: :user do
  email               'ux-test@buzzn.net'
  profile             { Fabricate(:profile_uxtest) }
  contracting_party   { Fabricate(:contracting_party) }
end







