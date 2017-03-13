# encoding: utf-8

Fabricator :user do
  email             { FFaker::Internet.email }
  password          '12345678'
  profile           { Fabricate(:profile) }
  created_at        { (rand*10).days.ago }
  bank_account      { Fabricate(:bank_account) }
  after_create { |user|
    user.confirm
  }
end


['input_register', 'output_register'].each do |register|
  Fabricator "user_with_friend_and_#{register}", from: :user do
    after_create { |user |
      friend = Fabricate("user_with_#{register}")
      user.friendships.create(friend: friend)
      friend.friendships.create(friend: user)
    }
  end

  Fabricator "user_with_#{register}", from: :user do
    after_create { |user|
      user.add_role(:manager, Fabricate(register, meter: Fabricate(:meter)))
    }
  end
end

Fabricator :admin, from: :user do
  after_create { |user| user.add_role(:admin) }
end

Fabricator :user_received_friendship_request, from: :user do
  after_create do |user|
    user2 = Fabricate(:user)
    Fabricate(:friendship_request, { sender: user2, receiver: user })
  end
end

Fabricator :user_with_friend, from: :user do
  after_create { |user |
    friend = Fabricate(:user)
    user.friendships.create(friend: friend)
    friend.friendships.create(friend: user)
  }
end

Fabricator :felix, from: :user do
  email               'felix@buzzn.net'
  profile             { Fabricate(:profile_felix) }
end

Fabricator :justus, from: :user do
  email       'justus@buzzn.net'
  profile     { Fabricate(:profile_justus) }
end

Fabricator :danusch, from: :user do
  email       'danusch@buzzn.net'
  profile     { Fabricate(:profile_danusch) }
end

Fabricator :thomas, from: :user do
  email       'thomas@buzzn.net'
  profile     { Fabricate(:profile_thomas) }
end

Fabricator :eva, from: :user do
  email       'eva@buzzn.net'
  profile     { Fabricate(:profile_eva) }
end

Fabricator :stefan, from: :user do
  email       'stefan@buzzn.net'
  profile     { Fabricate(:profile_stefan) }
end
Fabricator :karin, from: :user do
  email       'karin.smith@solfux.de'
  profile     { Fabricate(:profile_karin) }
end

Fabricator :pavel, from: :user do
  email       'pavel@buzzn.net'
  profile     { Fabricate(:profile_pavel) }
end

Fabricator :philipp, from: :user do
  email       'philipp@buzzn.net'
  profile     { Fabricate(:profile_philipp) }
end

Fabricator :christian, from: :user do
  email       'christian@buzzn.net'
  profile     { Fabricate(:profile_christian) }
end

Fabricator :jan_gerdes, from: :user do
  email     'jangerdes@stiftung-fuer-tierschutz.de'
  profile   { Fabricate(:profile_jangerdes) }
end

Fabricator :christian_schuetze, from: :user do
  email     'christian@schuetze.de'
  profile   { Fabricate(:profile_christian_schuetze) }
end

Fabricator :geloeschter_benutzer, from: :user do
  email     'sys@buzzn.net'
  profile   { Fabricate(:profile_geloeschter_benutzer) }
end

Fabricator :mustafa, from: :user do
  email       'mustafaakman@ymail.de'
  profile     { Fabricate(:profile_mustafa) }
end

Fabricator :kristian, from: :user do
  email       'm.kristian@web.de'
  profile     { Fabricate(:profile_kristian) }
end


#Ab hier: Hopf
Fabricator :hans_dieter_hopf, from: :user do
  email               'hans.dieter.hopf@gmail.de'
  profile             { Fabricate(:profile_hans_dieter_hopf) }
end

Fabricator :thomas_hopf, from: :user do
  email               'thomas.hopf@gmail.de'
  profile             { Fabricate(:profile_thomas_hopf) }
end

Fabricator :manuela_baier, from: :user do
  email               'manuela.baier@gmail.de'
  profile             { Fabricate(:profile_manuela_baier) }
end




#Ab hier: wagnis 4
Fabricator :dirk_mittelstaedt, from: :user do
  email               'dirk.mittelstaedt@t-online.de'
  profile             { Fabricate(:profile_dirk_mittelstaedt) }
end

Fabricator :manuel_dmoch, from: :user do
  email               'manuel.dmoch@gmail.com'
  profile             { Fabricate(:profile_manuel_dmoch) }
end

Fabricator :sibo_ahrens, from: :user do
  email               'sibo_ahrens@yahoo.de'
  profile             { Fabricate(:profile_sibo_ahrens) }
end

Fabricator :nicolas_sadoni, from: :user do
  email               'nicolas.sadoni@gmx.de'
  profile             { Fabricate(:profile_nicolas_sadoni) }
end

Fabricator :josef_neu, from: :user do
  email               'burger.neu@web.de'
  profile             { Fabricate(:profile_josef_neu) }
end

Fabricator :elisabeth_christiansen, from: :user do
  email               'elisa.christiansen@gmx.de'
  profile             { Fabricate(:profile_elisabeth_christiansen) }
end

Fabricator :florian_butz, from: :user do
  email               'flob@gmx.net'
  profile             { Fabricate(:profile_florian_butz) }
end

Fabricator :ulrike_bez, from: :user do
  email               'ulrike@bezmedien.com'
  profile             { Fabricate(:profile_ulrike_bez) }
end

Fabricator :rudolf_hassenstein, from: :user do
  email               'ruhn@arcor.de'
  profile             { Fabricate(:profile_rudolf_hassenstein) }
end



Fabricator :andreas_schlafer, from: :user do
  email               'andreas.schlafer@gmx.de'
  profile             { Fabricate(:profile_andreas_schlafer) }
end

Fabricator :luise_woerle, from: :user do
  email               'luise.woerle@t-online.de'
  profile             { Fabricate(:profile_luise_woerle) }
end

Fabricator :peter_waechter, from: :user do
  email               'info.peter.waechter@t-online.de'
  profile             { Fabricate(:profile_peter_waechter) }
end

Fabricator :sigrid_cycon, from: :user do
  email               'cycon.sigrid@t-online.de'
  profile             { Fabricate(:profile_sigrid_cycon) }
end

Fabricator :dietlind_klemm, from: :user do
  email               'dietlind.klemm@gmx.de'
  profile             { Fabricate(:profile_dietlind_klemm) }
end

Fabricator :wilhelm_wagner, from: :user do
  email               'bcw15@t-online.de'
  profile             { Fabricate(:profile_wilhelm_wagner) }
end

Fabricator :volker_letzner, from: :user do
  email               'vletzner@web.de'
  profile             { Fabricate(:profile_volker_letzner) }
end

#maria_mueller -> Kiosk
Fabricator :maria_mueller, from: :user do
  email               'mar_s1@gmx.de'
  profile             { Fabricate(:profile_maria_mueller) }
end

Fabricator :evang_pflege, from: :user do
  email               'email@ev-pflegedienst.de'
  profile             { Fabricate(:profile_evang_pflege) }
end

Fabricator :david_stadlmann, from: :user do
  email               'david.stadlmann@divad.de'
  profile             { Fabricate(:profile_david_stadlmann) }
end

Fabricator :doris_knaier, from: :user do
  email               'info@dorisknaier.de'
  profile             { Fabricate(:profile_doris_knaier) }
end

Fabricator :sabine_dumler, from: :user do
  email               'sabine.dumler@googlemail.com'
  profile             { Fabricate(:profile_sabine_dumler) }
end

Fabricator :uxtest_user, from: :user do
  email               'ux-test@buzzn.net'
  profile             { Fabricate(:profile_uxtest) }
end







#Ab hier: Hell & Warm (Forstenried)
Fabricator :markus_becher, from: :user do
  email               'markusbecher@hotmail.com'
  profile             { Fabricate(:profile_markus_becher) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 43')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Markus Becher') }
end

Fabricator :inge_brack, from: :user do
  email               'i.brack@yahoo.de'
  profile             { Fabricate(:profile_inge_brack) }
  address             { Fabricate(:address_limmat, street_number: 5, addition: 'M 21')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Inge Brack') }
end

Fabricator :peter_brack, from: :user do
  email               'peter_brack@web.de'
  profile             { Fabricate(:profile_peter_brack) }
  address             { Fabricate(:address_limmat, street_number: 5, addition: 'M 25')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Peter Brack') }
end

Fabricator :annika_brandl, from: :user do
  email               'nothing@nothing.de'
  profile             { Fabricate(:profile_annika_brandl) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 25')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Annika Brandl') }
end

Fabricator :gudrun_brandl, from: :user do
  email               'gudrun_brandl@gmx.de'
  profile             { Fabricate(:profile_gudrun_brandl) }
  address             { Fabricate(:address_limmat, street_number: 5, addition: 'M 14')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Gudrun Brandl') }
end

Fabricator :martin_braeunlich, from: :user do
  email               'mbraeunlich@arcor.de'
  profile             { Fabricate(:profile_martin_braeunlich) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 42')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Martin Bräunlich') }
end

Fabricator :daniel_bruno, from: :user do
  email               'daniel.bruno@gmx.net'
  profile             { Fabricate(:profile_daniel_bruno) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 22')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Daniel Bruno') }
end

Fabricator :zubair_butt, from: :user do
  email               'zubiedyta@web.de'
  profile             { Fabricate(:profile_zubair_butt) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 41')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Zubair Butt') }
end

Fabricator :maria_cerghizan, from: :user do
  email               'cerghizan_medias@yahoo.de'
  profile             { Fabricate(:profile_maria_cerghizan) }
  address             { Fabricate(:address_limmat, street_number: 5, addition: 'M 32')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Maria Cerghizan') }
end

Fabricator :stefan_csizmadia, from: :user do
  email               'nothing2@nothing.de'
  profile             { Fabricate(:profile_stefan_csizmadia) }
  address             { Fabricate(:address_limmat, street_number: 5, addition: 'M 13')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Stefan Csizmadia') }
end

Fabricator :patrick_fierley, from: :user do
  email               'remik.fierley@gmail.com'
  profile             { Fabricate(:profile_patrick_fierley) }
  address             { Fabricate(:address_limmat, street_number: 7, addition: 'S 33')}
  bank_account        { Fabricate.build(:bank_account_mustermann, holder: 'Patrick Fierley') }
end

Fabricator :maria_frank, from: :user do
  email               'info-bzd@t-online.de'
  profile             { Fabricate(:profile_maria_frank) }
end

Fabricator :eva_galow, from: :user do
  email               'e.galow@gmx.net'
  profile             { Fabricate(:profile_eva_galow) }
end

Fabricator :christel_guesgen, from: :user do
  email               'nothing3@nothing.de'
  profile             { Fabricate(:profile_christel_guesgen) }
end

Fabricator :gilda_hencke, from: :user do
  email               'gilda.hencke@gmx.de'
  profile             { Fabricate(:profile_gilda_hencke) }
end

Fabricator :uwe_hetzer, from: :user do
  email               'u_hetzer@web.de'
  profile             { Fabricate(:profile_uwe_hetzer) }
end

Fabricator :andreas_kapfer, from: :user do
  email               'lh-apotheke@gmx.de'
  profile             { Fabricate(:profile_andreas_kapfer) }
end

Fabricator :renate_koller, from: :user do
  email               'septembermusik@hotmail.de'
  profile             { Fabricate(:profile_renate_koller) }
end

Fabricator :thekla_lorber, from: :user do
  email               'stefan.lorber@gmx.de'
  profile             { Fabricate(:profile_thekla_lorber) }
end

Fabricator :ludwig_maassen, from: :user do
  email               'ludwig.maassen@me.com'
  profile             { Fabricate(:profile_ludwig_maassen) }
end

Fabricator :franz_petschler, from: :user do
  email               'franz.petschler@t-online.de'
  profile             { Fabricate(:profile_franz_petschler) }
end

Fabricator :anna_pfaffel, from: :user do
  email               'nothing4@nothing.de'
  profile             { Fabricate(:profile_anna_pfaffel) }
end

Fabricator :cornelia_roth, from: :user do
  email               'cornelia-roth@web.de'
  profile             { Fabricate(:profile_cornelia_roth) }
end

Fabricator :christiane_voigt, from: :user do
  email               'helgard.voigt@t-online.de'
  profile             { Fabricate(:profile_christiane_voigt) }
end

Fabricator :claudia_weber, from: :user do
  email               'weber.claudia@hotmail.de'
  profile             { Fabricate(:profile_claudia_weber) }
end

Fabricator :sissi_banos, from: :user do
  email               'sissi.banos@gmx.de'
  profile             { Fabricate(:profile_sissi_banos) }
end

Fabricator :laura_haeusler, from: :user do
  email               'laurahaeusler@gmx.de'
  profile             { Fabricate(:profile_laura_haeusler) }
end

Fabricator :bastian_hentschel, from: :user do
  email               'bastian.hentschel@gmx.de'
  profile             { Fabricate(:profile_bastian_hentschel) }
end

Fabricator :dagmar_holland, from: :user do
  email               'dagmar.holland@t-online.de'
  profile             { Fabricate(:profile_dagmar_holland) }
end

Fabricator :ahmad_majid, from: :user do
  email               'ahmad3@web.de'
  profile             { Fabricate(:profile_ahmad_majid) }
end

Fabricator :marinus_meiners, from: :user do
  email               'marinusm@t-online.de'
  profile             { Fabricate(:profile_marinus_meiners) }
end

Fabricator :wolfgang_pfaffel, from: :user do
  email               'nothing5@nothing.de'
  profile             { Fabricate(:profile_wolfgang_pfaffel) }
end

Fabricator :magali_thomas, from: :user do
  email               'borissa@web.de'
  profile             { Fabricate(:profile_magali_thomas) }
end

Fabricator :kathrin_kaisenberg, from: :user do
  email               'nothing6@nothing.de'
  profile             { Fabricate(:profile_kathrin_kaisenberg) }
end

Fabricator :christian_winkler, from: :user do
  email               'christianwinkler@online.de'
  profile             { Fabricate(:profile_christian_winkler) }
end

Fabricator :dorothea_wolff, from: :user do
  email               'thea.wolff@t-online.de'
  profile             { Fabricate(:profile_dorothea_wolff) }
end

Fabricator :esra_kwiek, from: :user do
  email               'esra.kwiek@gmx.de'
  profile             { Fabricate(:profile_esra_kwiek) }
end

Fabricator :felix_pfeiffer, from: :user do
  email               'felixpfeiffer@gmx.net'
  profile             { Fabricate(:profile_felix_pfeiffer) }
end

Fabricator :jorg_nasri, from: :user do
  email               'jorgnasri@yahoo.de'
  profile             { Fabricate(:profile_jorg_nasri) }
end

Fabricator :ruth_juergensen, from: :user do
  email               'ruth-d.tmg@hotmail.de'
  profile             { Fabricate(:profile_ruth_juergensen) }
end

Fabricator :rafal_jaskolka, from: :user do
  email               'jaskolkar@yahoo.de'
  profile             { Fabricate(:profile_rafal_jaskolka) }
end

Fabricator :elisabeth_gritzmann, from: :user do
  email               'lgritzmann@freenet.de'
  profile             { Fabricate(:profile_elisabeth_gritzmann) }
end

Fabricator :matthias_flegel, from: :user do
  email               'matthias@flegel-online.de'
  profile             { Fabricate(:profile_matthias_flegel) }
end

Fabricator :michael_goebl, from: :user do
  email               'michael.goebl@gruenholzwerkstatt.de'
  profile             { Fabricate(:profile_michael_goebl) }
end

Fabricator :joaquim_gongolo, from: :user do
  email               'jackgongolo@yahoo.de'
  profile             { Fabricate(:profile_joaquim_gongolo) }
end

Fabricator :patrick_haas, from: :user do
  email               'patrick_haas@hotmail.de'
  profile             { Fabricate(:profile_patrick_haas) }
end

Fabricator :gundula_herrberg, from: :user do
  email               'gundula.herrberg@gmx.de'
  profile             { Fabricate(:profile_gundula_herrberg) }
end

Fabricator :dominik_soelch, from: :user do
  email               'dominik.soelch@gmx.de'
  profile             { Fabricate(:profile_dominik_soelch) }
end

Fabricator :jessica_rensburg, from: :user do
  email               'sabiaefada@hotmail.com'
  profile             { Fabricate(:profile_jessica_rensburg) }
end

Fabricator :ulrich_hafen, from: :user do
  email               'hafenulrich@mac.com'
  profile             { Fabricate(:profile_ulrich_hafen) }
end

Fabricator :anke_merk, from: :user do
  email               'anke.merk@waldorfschule-msw.de'
  profile             { Fabricate(:profile_anke_merk) }
end

Fabricator :alex_erdl, from: :user do
  email               'a.erdl@mnet-online.de'
  profile             { Fabricate(:profile_alex_erdl) }
end

Fabricator :katrin_frische, from: :user do
  email               'franzmuenchen@yahoo.de'
  profile             { Fabricate(:profile_katrin_frische) }
end

Fabricator :claudia_krumm, from: :user do
  email               'claudia.krumm@freenet.de'
  profile             { Fabricate(:profile_claudia_krumm) }
end

Fabricator :rasim_abazovic, from: :user do
  email               'abasovicrasim@hotmail.de'
  profile             { Fabricate(:profile_rasim_abazovic) }
end

Fabricator :moritz_feith, from: :user do
  email               'moritzfeith@live.com'
  profile             { Fabricate(:profile_moritz_feith) }
end

Fabricator :irmgard_loderer, from: :user do
  email               'irmgard.loderer@gmx.de'
  profile             { Fabricate(:profile_irmgard_loderer) }
end

Fabricator :eunice_schueler, from: :user do
  email               'eunice.schueler@gmx.com'
  profile             { Fabricate(:profile_eunice_schueler) }
end

Fabricator :sara_stroedel, from: :user do
  email               'sara.stroedel@web.de'
  profile             { Fabricate(:profile_sara_stroedel) }
end

Fabricator :hannelore_voigt, from: :user do
  email               'voigt-forstenried@t-online.de'
  profile             { Fabricate(:profile_hannelore_voigt) }
end

Fabricator :roswitha_weber, from: :user do
  email               'weber.roswitha@web.de'
  profile             { Fabricate(:profile_roswitha_weber) }
end

Fabricator :alexandra_brunner, from: :user do
  email               'brunnerin@hotmail.de'
  profile             { Fabricate(:profile_alexandra_brunner) }
end

Fabricator :sww_ggmbh, from: :user do
  email               'ernst-birgit@sww-muenchen.de'
  profile             { Fabricate(:profile_sww_ggmbh) }
end

Fabricator :peter_schmidt, from: :user do
  email               'ps@arg.net'
  profile             { Fabricate(:profile_peter_schmidt) }
end
