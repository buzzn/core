# encoding: utf-8

Fabricator :profile do
  first_name  { FFaker::Name.first_name }
  last_name   { FFaker::Name.last_name }
  phone       { FFaker::PhoneNumber.phone_number }
  terms       true
  i = 0
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', "#{((i+=1)%60) + 1}.jpg")) }
  about_me    { FFaker::Lorem.sentence }
  website     { "http://www.#{FFaker::Internet.domain_name}" }
end


Fabricator :profile_felix, from: :profile do
  user_name   'ffaerber'
  first_name  'Felix'
  last_name   'Faerber'
  website     'http://www.ffaerber.com'
  facebook    'https://www.facebook.com/ffaerber'
  twitter     'https://twitter.com/ffaerber'
  xing        'https://www.xing.com/profile/Felix_Faerber'
  linkedin    'https://www.linkedin.com/profile/view?id=61766404'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'felix.jpg')) }
end

Fabricator :profile_justus, from: :profile do
  first_name  'Justus'
  last_name   'Schütze'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'justus.jpg')) }
end

Fabricator :profile_danusch, from: :profile do
  first_name  'Danusch'
  last_name   'Mahmoudi'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'danusch.jpg')) }
end

Fabricator :profile_thomas, from: :profile do
  first_name  'Thomas'
  last_name   'Theenhaus'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'thomas.jpg')) }
end

Fabricator :profile_martina, from: :profile do
  first_name  'Martina'
  last_name   'Raschke'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'martina.jpg')) }
end

Fabricator :profile_stefan, from: :profile do
  first_name  'Stefan'
  last_name   'Erbacher'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'stefan.jpg')) }
end

Fabricator :profile_karin, from: :profile do
  first_name  'Karin'
  last_name   'Smith'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'karin.jpg')) }
end

Fabricator :profile_ole, from: :profile do
  first_name  'Ole'
  last_name   'Vörsmann'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'ole.jpg')) }
end

Fabricator :profile_philipp, from: :profile do
  first_name  'Philipp'
  last_name   'Osswald'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'philipp.jpg')) }
end

Fabricator :profile_christian, from: :profile do
  first_name  'Christian'
  last_name   'Widmann'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'christian.jpg')) }
end



Fabricator :profile_jangerdes, from: :profile do
  first_name  'Jan'
  last_name   'Gerdes'
  #image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'christian.jpg')) }
end

Fabricator :profile_christian_schuetze, from: :profile do
  first_name  'Christian'
  last_name   'Schütze'
  image       { File.new(Rails.root.join('db', 'seed_assets', 'profiles', 'christian_schuetze.jpg')) }
end

Fabricator :profile_hans_dieter_hopf, from: :profile do
  first_name  'Hans Dieter'
  last_name   'Hopf'
end

Fabricator :profile_thomas_hopf, from: :profile do
  first_name  'Thomas'
  last_name   'Hopf'
end

Fabricator :profile_manuela_baier, from: :profile do
  first_name  'Manuela'
  last_name   'Baier'
end


Fabricator :profile_dirk_mittelstaedt, from: :profile do
  first_name  'Dirk'
  last_name   'Mittelstaedt'
end

Fabricator :profile_manuel_dmoch, from: :profile do
  first_name  'Manuel'
  last_name   'Dmoch'
end

Fabricator :profile_sibo_ahrens, from: :profile do
  first_name  'Sibo'
  last_name   'Ahrens'
end

Fabricator :profile_nicolas_sadoni, from: :profile do
  first_name  'Nicolas'
  last_name   'Sadoni'
end

Fabricator :profile_josef_neu, from: :profile do
  first_name  'Josef'
  last_name   'Neu'
end

Fabricator :profile_elisabeth_christiansen, from: :profile do
  first_name  'Elisabeth'
  last_name   'Christiansen'
end

Fabricator :profile_florian_butz, from: :profile do
  first_name  'Florian'
  last_name   'Butz'
end

Fabricator :profile_ulrike_bez, from: :profile do
  first_name  'Ulrike'
  last_name   'Bez'
end

Fabricator :profile_rudolf_hassenstein, from: :profile do
  first_name  'Rudolf'
  last_name   'Hassenstein'
end


Fabricator :profile_andreas_schlafer, from: :profile do
  first_name  'Andreas'
  last_name   'Schlafer'
end

Fabricator :profile_luise_woerle, from: :profile do
  first_name  'Luise'
  last_name   'Woerle'
end

Fabricator :profile_peter_waechter, from: :profile do
  first_name  'Peter'
  last_name   'Waechter'
end

Fabricator :profile_sigrid_cycon, from: :profile do
  first_name  'Sigird'
  last_name   'Cycon'
end

Fabricator :profile_dietlind_klemm, from: :profile do
  first_name  'Dietlind'
  last_name   'Klemm'
end

Fabricator :profile_wilhelm_wagner, from: :profile do
  first_name  'Wilhelm'
  last_name   'Wagner'
end

Fabricator :profile_volker_letzner, from: :profile do
  first_name  'Volker'
  last_name   'Letzner'
end

Fabricator :profile_maria_mueller, from: :profile do
  first_name  'Maria'
  last_name   'Mueller'
end

Fabricator :profile_evang_pflege, from: :profile do
  first_name  'Evangelischer'
  last_name   'Pflegedienst'
end

Fabricator :profile_david_stadlmann, from: :profile do
  first_name  'David'
  last_name   'Stadlmann'
end

Fabricator :profile_doris_knaier, from: :profile do
  first_name  'Doris'
  last_name   'Knaier'
end

Fabricator :profile_sabine_dumler, from: :profile do
  first_name  'Sabine'
  last_name   'Dumler'
end

Fabricator :profile_uxtest, from: :profile do
  first_name 'Test'
  last_name  'User'
end




#Ab hier: Hell & Warm (Forstenried)
Fabricator :profile_markus_becher, from: :profile do
  first_name 'Markus'
  last_name  'Becher'
end

Fabricator :profile_inge_brack, from: :profile do
  first_name 'Inge'
  last_name  'Brack'
end

Fabricator :profile_peter_brack, from: :profile do
  first_name 'Peter'
  last_name  'Brack'
end

Fabricator :profile_annika_brandl, from: :profile do
  first_name 'Annika'
  last_name  'Brandl'
end

Fabricator :profile_gudrun_brandl, from: :profile do
  first_name 'Gudrun'
  last_name  'Brandl'
end

Fabricator :profile_martin_braeunlich, from: :profile do
  first_name 'Martin'
  last_name  'Bräunlich'
end

Fabricator :profile_daniel_bruno, from: :profile do
  first_name 'Daniel'
  last_name  'Bruno'
end

Fabricator :profile_zubair_butt, from: :profile do
  first_name 'Zubair'
  last_name  'Butt'
end

Fabricator :profile_maria_cerghizan, from: :profile do
  first_name 'Maria'
  last_name  'Cerghizan'
end

Fabricator :profile_stefan_csizmadia, from: :profile do
  first_name 'Stefan'
  last_name  'Csizmadia'
end

Fabricator :profile_patrick_fierley, from: :profile do
  first_name 'Patrick'
  last_name  'Fierley'
end

Fabricator :profile_maria_frank, from: :profile do
  first_name 'Maria'
  last_name  'Frank'
end

Fabricator :profile_eva_galow, from: :profile do
  first_name 'Eva'
  last_name  'Galow'
end

Fabricator :profile_christel_guesgen, from: :profile do
  first_name 'Christel'
  last_name  'Guesgen'
end

Fabricator :profile_gilda_hencke, from: :profile do
  first_name 'Gilda'
  last_name  'Hencke'
end

Fabricator :profile_uwe_hetzer, from: :profile do
  first_name 'Uwe'
  last_name  'Hetzer'
end

Fabricator :profile_andreas_kapfer, from: :profile do
  first_name 'Andreas'
  last_name  'Kapfer'
end

Fabricator :profile_renate_koller, from: :profile do
  first_name 'Renate'
  last_name  'Koller'
end

Fabricator :profile_thekla_lorber, from: :profile do
  first_name 'Thekla'
  last_name  'Lorber'
end

Fabricator :profile_ludwig_maassen, from: :profile do
  first_name 'Ludwig'
  last_name  'Maaßen'
end

Fabricator :profile_franz_petschler, from: :profile do
  first_name 'Franz'
  last_name  'Petschler'
end

Fabricator :profile_anna_pfaffel, from: :profile do
  first_name 'Anna'
  last_name  'Pfaffel'
end

Fabricator :profile_cornelia_roth, from: :profile do
  first_name 'Cornelia'
  last_name  'Roth'
end

Fabricator :profile_christiane_voigt, from: :profile do
  first_name 'Christiane'
  last_name  'Voigt'
end

Fabricator :profile_claudia_weber, from: :profile do
  first_name 'Claudia'
  last_name  'Weber'
end

Fabricator :profile_sissi_banos, from: :profile do
  first_name 'Sissi'
  last_name  'Banos'
end

Fabricator :profile_laura_haeusler, from: :profile do
  first_name 'Laura'
  last_name  'Häusler'
end

Fabricator :profile_bastian_hentschel, from: :profile do
  first_name 'Bastian'
  last_name  'Hentschel'
end

Fabricator :profile_dagmar_holland, from: :profile do
  first_name 'Dagmar'
  last_name  'Holland'
end

Fabricator :profile_ahmad_majid, from: :profile do
  first_name 'Ahmad'
  last_name  'Majid'
end

Fabricator :profile_marinus_meiners, from: :profile do
  first_name 'Marinus'
  last_name  'Meiners'
end

Fabricator :profile_wolfgang_pfaffel, from: :profile do
  first_name 'Wolfgang'
  last_name  'Pfaffel'
end

Fabricator :profile_magali_thomas, from: :profile do
  first_name 'Magali'
  last_name  'Thomas'
end

Fabricator :profile_kathrin_kaisenberg, from: :profile do
  first_name 'Kathrin'
  last_name  'Kaisenberg'
end

Fabricator :profile_christian_winkler, from: :profile do
  first_name 'Christian'
  last_name  'Winkler'
end

Fabricator :profile_dorothea_wolff, from: :profile do
  first_name 'Dorothea'
  last_name  'Wolff'
end

Fabricator :profile_esra_kwiek, from: :profile do
  first_name 'Esra'
  last_name  'Kwiek'
end

Fabricator :profile_felix_pfeiffer, from: :profile do
  first_name 'Felix'
  last_name  'Pfeiffer'
end

Fabricator :profile_jorg_nasri, from: :profile do
  first_name 'Jorg'
  last_name  'Nasri'
end

Fabricator :profile_ruth_juergensen, from: :profile do
  first_name 'Ruth'
  last_name  'Jürgensen'
end

Fabricator :profile_rafal_jaskolka, from: :profile do
  first_name 'Rafal'
  last_name  'Jaskolka'
end

Fabricator :profile_elisabeth_gritzmann, from: :profile do
  first_name 'Elisabeth'
  last_name  'Gritzmann'
end

Fabricator :profile_matthias_flegel, from: :profile do
  first_name 'Matthias'
  last_name  'Flegel'
end

Fabricator :profile_michael_goebl, from: :profile do
  first_name 'Michael'
  last_name  'Göbl'
end

Fabricator :profile_joaquim_gongolo, from: :profile do
  first_name 'Joaquim'
  last_name  'Gongolo'
end

Fabricator :profile_patrick_haas, from: :profile do
  first_name 'Patrick'
  last_name  'Haas'
end

Fabricator :profile_gundula_herrberg, from: :profile do
  first_name 'Gundula'
  last_name  'Herrberg'
end

Fabricator :profile_dominik_soelch, from: :profile do
  first_name 'Dominik'
  last_name  'Sölch'
end

Fabricator :profile_jessica_rensburg, from: :profile do
  first_name 'Jessica'
  last_name  'Rensburg'
end

Fabricator :profile_ulrich_hafen, from: :profile do
  first_name 'Ulrich'
  last_name  'Hafen'
end

Fabricator :profile_anke_merk, from: :profile do
  first_name 'Anke'
  last_name  'Merk'
end

Fabricator :profile_alex_erdl, from: :profile do
  first_name 'Alex'
  last_name  'Erdl'
end

Fabricator :profile_katrin_frische, from: :profile do
  first_name 'Katrin'
  last_name  'Frische'
end

Fabricator :profile_claudia_krumm, from: :profile do
  first_name 'Claudia'
  last_name  'Krumm'
end

Fabricator :profile_rasim_abazovic, from: :profile do
  first_name 'Rasim'
  last_name  'Abazovic'
end

Fabricator :profile_moritz_feith, from: :profile do
  first_name 'Moritz'
  last_name  'Feith'
end

Fabricator :profile_irmgard_loderer, from: :profile do
  first_name 'Irmgard'
  last_name  'Loderer'
end

Fabricator :profile_eunice_schueler, from: :profile do
  first_name 'Eunice'
  last_name  'Schüler'
end

Fabricator :profile_sara_stroedel, from: :profile do
  first_name 'Sara'
  last_name  'Strödel'
end

Fabricator :profile_hannelore_voigt, from: :profile do
  first_name 'Hannelore'
  last_name  'Voigt'
end

Fabricator :profile_roswitha_weber, from: :profile do
  first_name 'Roswitha'
  last_name  'Weber'
end

Fabricator :profile_alexandra_brunner, from: :profile do
  first_name 'Alexandra'
  last_name  'Brunner'
end

Fabricator :profile_sww_ggmbh, from: :profile do
  first_name 'SWW'
  last_name  'gGmbH'
end

Fabricator :profile_peter_schmidt, from: :profile do
  first_name 'Peter'
  last_name  'Schmidt'
end

