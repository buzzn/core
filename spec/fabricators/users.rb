# encoding: utf-8

Fabricator :user do
  email             { FFaker::Internet.email }
  password          '12345678'
  profile           { Fabricate(:profile) }
  after_create { |user |
    user.confirm
  }
end

Fabricator :admin, from: :user do
  after_create { |user | user.add_role(:admin) }
end

Fabricator :user_with_metering_point, from: :user do
  after_create { |user|
    user.add_role(:manager, Fabricate(:metering_point))
  }
end

Fabricator :user_with_friend, from: :user do
  after_create { |user |
    friend = Fabricate(:user)
    user.friendships.create(friend: friend)
    friend.friendships.create(friend: user)
  }
end

Fabricator :user_with_friend_and_metering_point, from: :user do
  after_create { |user |
    friend = Fabricate(:user_with_metering_point)
    user.friendships.create(friend: friend)
    friend.friendships.create(friend: user)
  }
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

Fabricator :geloeschter_benutzer, from: :user do
  email     'sys@buzzn.net'
  profile   { Fabricate(:profile_geloeschter_benutzer) }
  contracting_party   { Fabricate(:contracting_party) }
end




#Ab hier: Hopf
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




#Ab hier: wagnis 4
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







#Ab hier: Hell & Warm (Forstenried)
Fabricator :markus_becher, from: :user do
  email               'markusbecher@hotmail.com'
  profile             { Fabricate(:profile_markus_becher) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :inge_brack, from: :user do
  email               'i.brack@yahoo.de'
  profile             { Fabricate(:profile_inge_brack) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :peter_brack, from: :user do
  email               'peter_brack@web.de'
  profile             { Fabricate(:profile_peter_brack) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :annika_brandl, from: :user do
  email               'nothing@nothing.de'
  profile             { Fabricate(:profile_annika_brandl) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :gudrun_brandl, from: :user do
  email               'gudrun_brandl@gmx.de'
  profile             { Fabricate(:profile_gudrun_brandl) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :martin_braeunlich, from: :user do
  email               'mbraeunlich@arcor.de'
  profile             { Fabricate(:profile_martin_braeunlich) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :daniel_bruno, from: :user do
  email               'daniel.bruno@gmx.net'
  profile             { Fabricate(:profile_daniel_bruno) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :zubair_butt, from: :user do
  email               'zubiedyta@web.de'
  profile             { Fabricate(:profile_zubair_butt) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :maria_cerghizan, from: :user do
  email               'cerghizan_medias@yahoo.de'
  profile             { Fabricate(:profile_maria_cerghizan) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :stefan_csizmadia, from: :user do
  email               'nothing2@nothing.de'
  profile             { Fabricate(:profile_stefan_csizmadia) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :patrick_fierley, from: :user do
  email               'remik.fierley@gmail.com'
  profile             { Fabricate(:profile_patrick_fierley) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :maria_frank, from: :user do
  email               'info-bzd@t-online.de'
  profile             { Fabricate(:profile_maria_frank) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :eva_galow, from: :user do
  email               'e.galow@gmx.net'
  profile             { Fabricate(:profile_eva_galow) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :christel_guesgen, from: :user do
  email               'nothing3@nothing.de'
  profile             { Fabricate(:profile_christel_guesgen) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :gilda_hencke, from: :user do
  email               'gilda.hencke@gmx.de'
  profile             { Fabricate(:profile_gilda_hencke) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :uwe_hetzer, from: :user do
  email               'u_hetzer@web.de'
  profile             { Fabricate(:profile_uwe_hetzer) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :andreas_kapfer, from: :user do
  email               'lh-apotheke@gmx.de'
  profile             { Fabricate(:profile_andreas_kapfer) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :renate_koller, from: :user do
  email               'septembermusik@hotmail.de'
  profile             { Fabricate(:profile_renate_koller) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :thekla_lorber, from: :user do
  email               'stefan.lorber@gmx.de'
  profile             { Fabricate(:profile_thekla_lorber) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :ludwig_maassen, from: :user do
  email               'ludwig.maassen@me.com'
  profile             { Fabricate(:profile_ludwig_maassen) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :franz_petschler, from: :user do
  email               'franz.petschler@t-online.de'
  profile             { Fabricate(:profile_franz_petschler) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :anna_pfaffel, from: :user do
  email               'nothing4@nothing.de'
  profile             { Fabricate(:profile_anna_pfaffel) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :cornelia_roth, from: :user do
  email               'cornelia-roth@web.de'
  profile             { Fabricate(:profile_cornelia_roth) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :christiane_voigt, from: :user do
  email               'helgard.voigt@t-online.de'
  profile             { Fabricate(:profile_christiane_voigt) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :claudia_weber, from: :user do
  email               'weber.claudia@hotmail.de'
  profile             { Fabricate(:profile_claudia_weber) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :sissi_banos, from: :user do
  email               'sissi.banos@gmx.de'
  profile             { Fabricate(:profile_sissi_banos) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :laura_haeusler, from: :user do
  email               'laurahaeusler@gmx.de'
  profile             { Fabricate(:profile_laura_haeusler) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :bastian_hentschel, from: :user do
  email               'bastian.hentschel@gmx.de'
  profile             { Fabricate(:profile_bastian_hentschel) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :dagmar_holland, from: :user do
  email               'dagmar.holland@t-online.de'
  profile             { Fabricate(:profile_dagmar_holland) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :ahmad_majid, from: :user do
  email               'ahmad3@web.de'
  profile             { Fabricate(:profile_ahmad_majid) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :marinus_meiners, from: :user do
  email               'marinusm@t-online.de'
  profile             { Fabricate(:profile_marinus_meiners) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :wolfgang_pfaffel, from: :user do
  email               'nothing5@nothing.de'
  profile             { Fabricate(:profile_wolfgang_pfaffel) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :magali_thomas, from: :user do
  email               'borissa@web.de'
  profile             { Fabricate(:profile_magali_thomas) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :kathrin_kaisenberg, from: :user do
  email               'nothing6@nothing.de'
  profile             { Fabricate(:profile_kathrin_kaisenberg) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :christian_winkler, from: :user do
  email               'christianwinkler@online.de'
  profile             { Fabricate(:profile_christian_winkler) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :dorothea_wolff, from: :user do
  email               'thea.wolff@t-online.de'
  profile             { Fabricate(:profile_dorothea_wolff) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :esra_kwiek, from: :user do
  email               'esra.kwiek@gmx.de'
  profile             { Fabricate(:profile_esra_kwiek) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :felix_pfeiffer, from: :user do
  email               'felixpfeiffer@gmx.net'
  profile             { Fabricate(:profile_felix_pfeiffer) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :jorg_nasri, from: :user do
  email               'jorgnasri@yahoo.de'
  profile             { Fabricate(:profile_jorg_nasri) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :ruth_juergensen, from: :user do
  email               'ruth-d.tmg@hotmail.de'
  profile             { Fabricate(:profile_ruth_juergensen) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :rafal_jaskolka, from: :user do
  email               'jaskolkar@yahoo.de'
  profile             { Fabricate(:profile_rafal_jaskolka) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :elisabeth_gritzmann, from: :user do
  email               'lgritzmann@freenet.de'
  profile             { Fabricate(:profile_elisabeth_gritzmann) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :matthias_flegel, from: :user do
  email               'matthias@flegel-online.de'
  profile             { Fabricate(:profile_matthias_flegel) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :michael_goebl, from: :user do
  email               'michael.goebl@gruenholzwerkstatt.de'
  profile             { Fabricate(:profile_michael_goebl) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :joaquim_gongolo, from: :user do
  email               'jackgongolo@yahoo.de'
  profile             { Fabricate(:profile_joaquim_gongolo) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :patrick_haas, from: :user do
  email               'patrick_haas@hotmail.de'
  profile             { Fabricate(:profile_patrick_haas) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :gundula_herrberg, from: :user do
  email               'gundula.herrberg@gmx.de'
  profile             { Fabricate(:profile_gundula_herrberg) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :dominik_soelch, from: :user do
  email               'dominik.soelch@gmx.de'
  profile             { Fabricate(:profile_dominik_soelch) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :jessica_rensburg, from: :user do
  email               'sabiaefada@hotmail.com'
  profile             { Fabricate(:profile_jessica_rensburg) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :ulrich_hafen, from: :user do
  email               'hafenulrich@mac.com'
  profile             { Fabricate(:profile_ulrich_hafen) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :anke_merk, from: :user do
  email               'anke.merk@waldorfschule-msw.de'
  profile             { Fabricate(:profile_anke_merk) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :alex_erdl, from: :user do
  email               'a.erdl@mnet-online.de'
  profile             { Fabricate(:profile_alex_erdl) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :katrin_frische, from: :user do
  email               'franzmuenchen@yahoo.de'
  profile             { Fabricate(:profile_katrin_frische) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :claudia_krumm, from: :user do
  email               'claudia.krumm@freenet.de'
  profile             { Fabricate(:profile_claudia_krumm) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :rasim_abazovic, from: :user do
  email               'abasovicrasim@hotmail.de'
  profile             { Fabricate(:profile_rasim_abazovic) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :moritz_feith, from: :user do
  email               'moritzfeith@live.com'
  profile             { Fabricate(:profile_moritz_feith) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :irmgard_loderer, from: :user do
  email               'irmgard.loderer@gmx.de'
  profile             { Fabricate(:profile_irmgard_loderer) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :eunice_schueler, from: :user do
  email               'eunice.schueler@gmx.com'
  profile             { Fabricate(:profile_eunice_schueler) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :sara_stroedel, from: :user do
  email               'sara.stroedel@web.de'
  profile             { Fabricate(:profile_sara_stroedel) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :hannelore_voigt, from: :user do
  email               'voigt-forstenried@t-online.de'
  profile             { Fabricate(:profile_hannelore_voigt) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :roswitha_weber, from: :user do
  email               'weber.roswitha@web.de'
  profile             { Fabricate(:profile_roswitha_weber) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :alexandra_brunner, from: :user do
  email               'brunnerin@hotmail.de'
  profile             { Fabricate(:profile_alexandra_brunner) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :sww_ggmbh, from: :user do
  email               'ernst-birgit@sww-muenchen.de'
  profile             { Fabricate(:profile_sww_ggmbh) }
  contracting_party   { Fabricate(:contracting_party) }
end

Fabricator :peter_schmidt, from: :user do
  email               'ps@arg.net'
  profile             { Fabricate(:profile_peter_schmidt) }
  contracting_party   { Fabricate(:contracting_party) }
end
