# coding: utf-8
Fabricator :meter do
  manufacturer_name           'ferraris'
  manufacturer_product_name    'AS 1440'
  manufacturer_product_serialnumber  { Random.new_seed.to_s.slice(0, 7) }
  metering_type { Buzzn::Zip2Price.types.first }
end

Fabricator :easy_meter_q3d, from: :meter  do
  manufacturer_name            'easy_meter'
  manufacturer_product_name    'Q3D'
  smart true
end


Fabricator :easy_meter_q3d_with_input_register, from: :easy_meter_q3d  do
  input_register
end

Fabricator :easy_meter_q3d_with_output_register, from: :easy_meter_q3d  do
  output_register
end


Fabricator :easy_meter_q3d_with_output_register_and_manager, from: :easy_meter_q3d  do
  output_register {[Fabricate(:output_register_with_manager)]}
end

Fabricator :easy_meter_q3d_with_in_output_register, from: :easy_meter_q3d  do
  after_create { |meter|
    Fabricate(:input_register, meter: meter)
    Fabricate(:output_register_with_manager, meter: meter)
  }
end

Fabricator :easy_meter_q3d_with_input_register_and_manager, from: :easy_meter_q3d do
  after_create { |meter|
    register = Fabricate(:input_register, meter: meter)
    user = Fabricate(:user)
    user.add_role(:manager, register)
  }
end

Fabricator :easymeter_fixed_serial, from: :easy_meter_q3d do
  manufacturer_product_serialnumber '1234567890'
  after_create { |meter|
    Fabricate(:input_register, meter: meter)
    Fabricate(:output_register_readable_by_world, meter: meter)
  }
end

# Justus Übergabe
Fabricator :easymeter_60139082, from: :easy_meter_q3d do
  manufacturer_product_serialnumber '60139082'
  after_create { |meter|
    Fabricate(:register_z1a, meter: meter)
    Fabricate(:register_z1b, meter: meter)
    meter.discovergy_broker = Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}")
  }
end

# Justus PV
Fabricator :easymeter_60051599, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '60051599'
  after_create { |meter|
    Fabricate(:register_z2, meter: meter)
    meter.discovergy_broker = Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}")
  }
end

# Justus Ladestation
Fabricator :easymeter_60051559, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '60051559'
  after_create { |meter|
    Fabricate(:register_z3, meter: meter)
    meter.discovergy_broker = Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}")
  }
end

# Justus BHKW
Fabricator :easymeter_60051560, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '60051560'
  after_create { |meter|
    Fabricate(:register_z4, meter: meter)
    meter.discovergy_broker = Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}")
  }
end


# Justus Abgrenzung
Fabricator :easymeter_60051600, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '60051600'
  after_create { |meter|
    Fabricate(:register_z5, meter: meter)
    meter.discovergy_broker = Fabricate(:discovergy_broker, resource: meter, external_id: "EASYMETER_#{meter.manufacturer_product_serialnumber}")
  }
end

# Justus verbrauch
Fabricator :easymeter_1124001747, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '1124001747'
end


# Mustafa verbrauch
Fabricator :easymeter_60232612, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '60232612'
end

# Stefan easymeter fur verbrauch
Fabricator :easymeter_1024000034, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '1024000034'
end


# karins meter fur die pv anlange
Fabricator :easymeter_60051431, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '60051431'
end




# Z1  Nr. 60118470 für Hans-Dieter Hopf  (Zweirichtungszähler)
Fabricator :easymeter_60118470, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60118470'
end

# Z2   Nr. 60009316 für BHKW Erzeugung (Einrichtungszähler Einspeisung)
Fabricator :easymeter_60009316, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009316'
end

# ZN1 Nr. 60009272 für Thomas Hopf  (Einrichtungszähler Bezug)
Fabricator :easymeter_60009272, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009272'
end

# ZN2 Nr. 60009348 für Mauela Beier (Einrichtungszähler Bezug)
Fabricator :easymeter_60009348, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009348'
end




# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :easymeter_60138988, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60138988'
end

# Nr. 60009269 für Philipp Oßwald (Einrichtungszähler Bezug)
Fabricator :easymeter_60009269, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009269'
end

Fabricator :easymeter_60232499, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60232499'
end

Fabricator :amperix_60232AMPE, from: :meter do
  manufacturer_name                   'amperix'
  manufacturer_product_name           'AMP'
  manufacturer_product_serialnumber   '60232AMPE'
end


# Meter für virtuellen MP für Hopf
Fabricator :virtual_meter_hopf, from: :meter do
  manufacturer_name                   ''
  manufacturer_product_name           ''
  manufacturer_product_serialnumber   '123456'
end



# wagnis 4
Fabricator :easymeter_60009416, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009416'
end
# wagnis 4
Fabricator :easymeter_60009419, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009419'
end
# wagnis 4
Fabricator :easymeter_60009415, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009415'
end
# wagnis 4
Fabricator :easymeter_60009418, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009418'
end
# wagnis 4
Fabricator :easymeter_60009411, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009411'
end
# wagnis 4
Fabricator :easymeter_60009410, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009410'
end
# wagnis 4
Fabricator :easymeter_60009407, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009407'

end
# wagnis 4
Fabricator :easymeter_60009409, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009409'
end
# wagnis 4
Fabricator :easymeter_60009435, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009435'
end
# wagnis 4
Fabricator :easymeter_60009420, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009420'
end
# Wagnis 4 PV
Fabricator :easymeter_60118460, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60118460'
end
#Wagnis 4 - Allgemeinstrom Haus Nord
Fabricator :easymeter_60009386, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009386'
end
#Wagnis 4 - Allgemeinstrom Haus Ost
Fabricator :easymeter_60009445, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009445'
end
#Wagnis 4 - Gäste Haus Ost 1+2
Fabricator :easymeter_60009446, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009446'
end
#Wagnis 4 - Laden EG
Fabricator :easymeter_60009390, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009390'
end
#Wagnis 4 - Nord Wohnung 01
Fabricator :easymeter_60009387, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009387'
end
#Wagnis 4 - Nord Wohnung 10
Fabricator :easymeter_60009438, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009438'
end
#Wagnis 4 - Nord Wohnung 12
Fabricator :easymeter_60009440, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009440'
end
#Wagnis 4 - Nord Wohnung 15
Fabricator :easymeter_60009404, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009404'
end
#Wagnis 4 - Nord Wohnung 17
Fabricator :easymeter_60009405, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '600093405'
end
#Wagnis 4 - Nord Wohnung 18
Fabricator :easymeter_60009422, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009422'
end
#Wagnis 4 - Nord Wohnung 19
Fabricator :easymeter_60009425, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009425'
end
#Wagnis 4 - Nord Wohnung 20
Fabricator :easymeter_60009402, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009402'
end
#Wagnis 4 - Ost 03
Fabricator :easymeter_60009429, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009429'
end
#Wagnis 4 - Ost Wohnung 12
Fabricator :easymeter_60009393, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009393'
end
#Wagnis 4 - Ost Wohnung 13
Fabricator :easymeter_60009442, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009442'
end
#Wagnis 4 - Ost Wohnung 15
Fabricator :easymeter_60009441, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009441'
end
#Wagnis 4 - Übergabe
Fabricator :easymeter_60118484, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60118484'
end





# Pickel
Fabricator :easymeter_60051562, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051562'
end






#Ab hier: Hell & Warm (Forstenried)
#Markus Becher
Fabricator :easymeter_60051595, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051595'
end

#inge_brack
Fabricator :easymeter_60051547, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051547'
end

#peter brack
Fabricator :easymeter_60051620, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051620'
end

#annika brandl
Fabricator :easymeter_60051602, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051602'
end

#gudrun brandl
Fabricator :easymeter_60051618, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051618'
end

#martin bräunlich
Fabricator :easymeter_60051557, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051557'
end

#daniel bruno
Fabricator :easymeter_60051596, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051596'
end

#zubair butt
Fabricator :easymeter_60051558, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051558'
end

#maria cerghizan
Fabricator :easymeter_60051551, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051551'
end

#stefan csizmadia
Fabricator :easymeter_60051619, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051619'
end

#patrick fierley
Fabricator :easymeter_60051556, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051556'
end

#maria frank
Fabricator :easymeter_60051617, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051617'
end

#eva galow
Fabricator :easymeter_60051555, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051555'
end

#christel guesgen
Fabricator :easymeter_60051616, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051616'
end

#gilda hencke
Fabricator :easymeter_60051615, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051615'
end

#uwe hetzer
Fabricator :easymeter_60051546, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051546'
end

#andreas kapfer
Fabricator :easymeter_60051553, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051553'
end

#renate koller
Fabricator :easymeter_60051601, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051601'
end

#thekla lorber
Fabricator :easymeter_60051568, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051568'
end

#ludwig maaßen
Fabricator :easymeter_60051610, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051610'
end

#franz petschler
Fabricator :easymeter_60051537, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051537'
end

#anna pfaffel
Fabricator :easymeter_60051564, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051564'
end

#cornelia roth
Fabricator :easymeter_60051572, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051572'
end

#christian voigt
Fabricator :easymeter_60051552, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051552'
end

#claudia weber
Fabricator :easymeter_60051567, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051567'
end

#sissi banos
Fabricator :easymeter_60051586, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051586'
end

#laura häusler
Fabricator :easymeter_60051540, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051540'
end

#bastian hentschel
Fabricator :easymeter_60051578, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051578'
end

#dagmar holland
Fabricator :easymeter_60051597, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051597'
end

#ahmad majid
Fabricator :easymeter_60051541, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051541'
end

#marinus meiners
Fabricator :easymeter_60051570, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051570'
end

#wolfgang pfaffel
Fabricator :easymeter_60051548, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051548'
end

#magali thomas
Fabricator :easymeter_60051612, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051612'
end

#kathrin kaisenberg
Fabricator :easymeter_60051549, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051549'
end

#christian winkler
Fabricator :easymeter_60051587, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051587'
end

#dorothea wolff
Fabricator :easymeter_60051566, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051566'
end

#esra kwiek
Fabricator :easymeter_60051592, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051592'
end

#felix pfeiffer
Fabricator :easymeter_60051580, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051580'
end

#jorg nasri
Fabricator :easymeter_60051538, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051538'
end

#ruth jürgensen
Fabricator :easymeter_60051590, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051590'
end

#rafal jaskolka
Fabricator :easymeter_60051588, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051588'
end

#elisabeth gritzmann
Fabricator :easymeter_60051543, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051543'
end

#matthias flegel
Fabricator :easymeter_60051582, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051582'
end

#michael göbl
Fabricator :easymeter_60051539, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051539'
end

#joaquim gongolo
Fabricator :easymeter_60051545, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051545'
end

#patrick haas
Fabricator :easymeter_60051614, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051614'
end

#gundula herrenberg
Fabricator :easymeter_60051550, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051550'
end

#dominik sölch
Fabricator :easymeter_60051573, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051573'
end

#jessica rensburg
Fabricator :easymeter_60051571, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051571'
end

#ulrich hafen
Fabricator :easymeter_60051544, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051544'
end

#anke merk
Fabricator :easymeter_60051594, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051594'
end

#alex erdl
Fabricator :easymeter_60051583, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051583'
end

#katrin frische
Fabricator :easymeter_60051604, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051604'
end

#claudia krumm
Fabricator :easymeter_60051593, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051593'
end

#rasim abazovic
Fabricator :easymeter_60051613, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051613'
end

#moritz feith
Fabricator :easymeter_60051611, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051611'
end

#irmgard loderer
Fabricator :easymeter_60051609, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051609'
end

#eunice schüler
Fabricator :easymeter_60051554, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051554'
end

#sara strödel
Fabricator :easymeter_60051585, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051585'
end

#hannelore voigt
Fabricator :easymeter_60051621, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051621'
end

#roswitha weber
Fabricator :easymeter_60051565, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051565'
end

# #alexandra brunner
# Fabricator :easymeter_6005195, from: :easy_meter_q3d do
#  manufacturer_product_serialnumber   '60051562'
# end

# #sww ggmbh
# Fabricator :easymeter_6005195, from: :easy_meter_q3d do
#  manufacturer_product_serialnumber   '60051562'
#  meter          { Fabricate(:easymeter_60051595) }
# end

# #peter schmidt
# Fabricator :easymeter_6005195, from: :easy_meter_q3d do
#  manufacturer_product_serialnumber   '60051562'
# end


#abgrenzung pv
Fabricator :easymeter_60009484, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009484'
end

#bhkw1
Fabricator :easymeter_60138947, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60138947'
end

#bhkw2
Fabricator :easymeter_60138943, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60138943'
end

#pv
Fabricator :easymeter_1338000816, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '1338000816'
end

#schule
Fabricator :easymeter_60009485, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009485'
end

#hst_mitte
Fabricator :easymeter_1338000818, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '1338000818'
end

#übergabe in
Fabricator :easymeter_1305004864, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '1305004864'
end

# #übergabe out
# Fabricator :easymeter_1305004864, from: :easy_meter_q3d do
#   manufacturer_product_serialnumber   '1305004864'
# end

# Fabricator :virtual_forstenried_erzeugung, from: :meter do
#   manufacturer_name                   ''
#   manufacturer_product_name           ''
#   manufacturer_product_serialnumber   '1234567'
#   after_create { |meter|
#     meter.registers << Fabricate(:register_forstenried_erzeugung)
#     meter.save
#   }
# end

# Fabricator :virtual_forstenried_bezug, from: :meter do
#   manufacturer_name                   ''
#   manufacturer_product_name           ''
#   manufacturer_product_serialnumber   '12345678'
# end




Fabricator :ferraris_001_amperix, from: :meter do
  manufacturer_name                   'ferraris'
  manufacturer_product_name           'xy'
  manufacturer_product_serialnumber   '001'
end
