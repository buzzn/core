# coding: utf-8
Fabricator :meter, class_name: Meter::Real do
  registers                           { [Fabricate.build([:input_register, :output_register].sample)] }
  manufacturer_name                   'ferraris'
  manufacturer_product_name           'AS 1440'
  manufacturer_product_serialnumber   { Random.new_seed.to_s.slice(0, 7) }
  created_at                          { (rand*10).days.ago }
  ownership                           Meter::Base::BUZZN_SYSTEMS
  metering_type                       Meter::Base::SMART_METER
  meter_size                          Meter::Base::EDL40
  mode                                'one-way'
  measurement_capture                 'some-capture'
  mounting_method                     Meter::Base::THREE_POINT_HANGING
  build_year                          { 5.years.ago }
  calibrated_till                     { 5.years.from_now }
  section                             'electricity'
  metering_point_type                 'metering_point'
  voltage_level                       Meter::Base::LOW_LEVEL
  cycle_interval                      Meter::Base::YEARLY
  send_data_dso                       false
  remote_readout                      true
  tariff                              Meter::Base::ONE_TARIFF
  data_logging                        Meter::Base::REMOTE
  manufacturer_number                 { Random.new_seed.to_s.slice(0, 12) }
  data_provider_name                  'Discovergy'
end

Fabricator :real_meter, from: :meter do
  manufacturer_name           { Meter::Real.manufacturer_names.sample }
  manufacturer_product_name    { FFaker::Name.name }
end

Fabricator :virtual_meter, class_name: Meter::Virtual do
  register                    { Fabricate.build(:virtual_register, direction: [:in, :out].sample).attributes }
  manufacturer_product_serialnumber  { Random.new_seed.to_s.slice(0, 7) }
end

[:input, :output].each do |mode|
  Fabricator "#{mode}_meter", class_name: Meter::Real do
    registers                   { [Fabricate.build("#{mode}_register")] }
    manufacturer_name           { Meter::Real.manufacturer_names.sample }
    manufacturer_product_name    { FFaker::Name.name }
    manufacturer_product_serialnumber  { Random.new_seed.to_s.slice(0, 7) }
  end
end

Fabricator :easy_meter_q3d, from: :meter  do
  manufacturer_name            'easy_meter'
  manufacturer_product_name    'Q3D'
  smart true
end

# Justus Übergabe
Fabricator :easymeter_60139082, from: :easy_meter_q3d do
  manufacturer_product_serialnumber '60139082'
  registers { [Fabricate.build(:register_z1a), Fabricate.build(:register_z1b)] }
end

# Justus PV
Fabricator :easymeter_60051599, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '60051599'
  registers { [Fabricate.build(:register_z2)] }
end

# Justus Ladestation
Fabricator :easymeter_60051559, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '60051559'
  registers { [Fabricate.build(:register_z3)] }
end

# Justus BHKW
Fabricator :easymeter_60051560, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '60051560'
  registers { [Fabricate.build(:register_z4)] }
end


# Justus Abgrenzung
Fabricator :easymeter_60051600, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '60051600'
  registers { [Fabricate.build(:register_z5)] }
end

# Christian Schütze verbrauch
Fabricator :easymeter_1124001747, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '1124001747'
  registers [Fabricate.build(:register_cs_1)]
  after_create do |meter|
    register = meter.input_register
    christian_schuetze = Fabricate(:christian_schuetze)
    christian_schuetze.add_role(:manager, register)
    christian_schuetze.add_role(:member, register)
  end
end

Fabricator :virtual_meter_fichtenweg8, from: :virtual_meter do
  register { Fabricate.build(:virtual_register, direction: 'in').attributes}
end


# Mustafa verbrauch
Fabricator :easymeter_60232612, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60232612'
  registers [Fabricate.build(:register_60232612)]
end

# Stefan easymeter fur BHKW
Fabricator :easymeter_1024000034, from: :easy_meter_q3d do
  manufacturer_product_serialnumber  '1024000034'
  registers { [Fabricate.build(:register_stefans_bhkw)] }
end


# karins meter fur die pv anlange
Fabricator :easymeter_60051431, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051431'
  registers [Fabricate.build(:register_pv_karin)]
end




# Z1  Nr. 60118470 für Hans-Dieter Hopf  (Zweirichtungszähler)
Fabricator :easymeter_60118470, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60118470'
  registers [Fabricate.build(:register_60118470)]
end

# Z2   Nr. 60009316 für BHKW Erzeugung (Einrichtungszähler Einspeisung)
Fabricator :easymeter_60009316, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009316'
  registers [Fabricate.build(:register_60009316)]
end

# ZN1 Nr. 60009272 für Thomas Hopf  (Einrichtungszähler Bezug)
Fabricator :easymeter_60009272, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009272'
  registers [Fabricate.build(:register_60009272)]
end

# ZN2 Nr. 60009348 für Mauela Beier (Einrichtungszähler Bezug)
Fabricator :easymeter_60009348, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009348'
  registers [Fabricate.build(:register_60009348)]
end




# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :easymeter_60138988, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60138988'
  registers [Fabricate.build(:register_60138988)]
end

# Nr. 60009269 für Philipp Oßwald (Einrichtungszähler Bezug)
Fabricator :easymeter_60009269, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009269'
  registers [Fabricate.build(:register_60009269)]
end

# Nr. 60232499 für Thomas Theenhaus (Einrichtungszähler Bezug)
Fabricator :easymeter_60232499, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60232499'
  registers [Fabricate.build(:register_60232499)]
end

Fabricator :amperix_60232AMPE, from: :meter do
  manufacturer_name                   'amperix'
  manufacturer_product_name           'AMP'
  manufacturer_product_serialnumber   '60232AMPE'
end


# Meter für virtuellen MP für Hopf
Fabricator :virtual_meter_hopf, from: :virtual_meter do
  manufacturer_product_serialnumber   '123456'
  #TODO make virtual-meter contructor more flexible to allow
  # build VirtualRegister as well
  register { Fabricate.build(:register_hdh).attributes }
end



# wagnis 4
Fabricator :easymeter_60009416, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009416'
  registers [Fabricate.build(:register_60009416)]
end
# wagnis 4
Fabricator :easymeter_60009419, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009419'
  registers [Fabricate.build(:register_60009419)]
end
# wagnis 4
Fabricator :easymeter_60009415, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009415'
  registers [Fabricate.build(:register_60009415)]
end
# wagnis 4
Fabricator :easymeter_60009418, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009418'
  registers [Fabricate.build(:register_60009418)]
end
# wagnis 4
Fabricator :easymeter_60009411, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009411'
  registers [Fabricate.build(:register_60009411)]
end
# wagnis 4
Fabricator :easymeter_60009410, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009410'
  registers [Fabricate.build(:register_60009410)]
end
# wagnis 4
Fabricator :easymeter_60009407, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009407'
  registers [Fabricate.build(:register_60009407)]

end
# wagnis 4
Fabricator :easymeter_60009409, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009409'
  registers [Fabricate.build(:register_60009409)]
end
# wagnis 4
Fabricator :easymeter_60009435, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009435'
  registers [Fabricate.build(:register_60009435)]
end
# wagnis 4
Fabricator :easymeter_60009420, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009420'
  registers [Fabricate.build(:register_60009420)]
end
# Wagnis 4 PV
Fabricator :easymeter_60118460, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60118460'
  registers [Fabricate.build(:register_60118460)]
end
#Wagnis 4 - Allgemeinstrom Haus Nord
Fabricator :easymeter_60009386, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009386'
  registers [Fabricate.build(:register_60009386)]
end
#Wagnis 4 - Allgemeinstrom Haus Ost
Fabricator :easymeter_60009445, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009445'
  registers [Fabricate.build(:register_60009445)]
end
#Wagnis 4 - Gäste Haus Ost 1+2
Fabricator :easymeter_60009446, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009446'
  registers [Fabricate.build(:register_60009446)]
end
#Wagnis 4 - Laden EG
Fabricator :easymeter_60009390, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009390'
  registers [Fabricate.build(:register_60009390)]
end
#Wagnis 4 - Nord Wohnung 01
Fabricator :easymeter_60009387, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009387'
  registers [Fabricate.build(:register_60009387)]
end
#Wagnis 4 - Nord Wohnung 10
Fabricator :easymeter_60009438, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009438'
  registers [Fabricate.build(:register_60009438)]
end
#Wagnis 4 - Nord Wohnung 12
Fabricator :easymeter_60009440, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009440'
  registers [Fabricate.build(:register_60009440)]
end
#Wagnis 4 - Nord Wohnung 15
Fabricator :easymeter_60009404, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009404'
  registers [Fabricate.build(:register_60009404)]
end
#Wagnis 4 - Nord Wohnung 17
Fabricator :easymeter_60009405, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009405'
  registers [Fabricate.build(:register_60009405)]
end
#Wagnis 4 - Nord Wohnung 18
Fabricator :easymeter_60009422, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009422'
  registers [Fabricate.build(:register_60009422)]
end
#Wagnis 4 - Nord Wohnung 19
Fabricator :easymeter_60009425, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009425'
  registers [Fabricate.build(:register_60009425)]
end
#Wagnis 4 - Nord Wohnung 20
Fabricator :easymeter_60009402, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009402'
  registers [Fabricate.build(:register_60009402)]
end
#Wagnis 4 - Ost 03
Fabricator :easymeter_60009429, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009429'
  registers [Fabricate.build(:register_60009429)]
end
#Wagnis 4 - Ost Wohnung 12
Fabricator :easymeter_60009393, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009393'
  registers [Fabricate.build(:register_60009393)]
end
#Wagnis 4 - Ost Wohnung 13
Fabricator :easymeter_60009442, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009442'
  registers [Fabricate.build(:register_60009442)]
end
#Wagnis 4 - Ost Wohnung 15
Fabricator :easymeter_60009441, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009441'
  registers [Fabricate.build(:register_60009441)]
end
#Wagnis 4 - Übergabe
Fabricator :easymeter_60118484, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60118484'
  registers [Fabricate.build(:register_60118484)]
end





# Pickel
Fabricator :easymeter_60051562, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051562'
  registers [Fabricate.build(:register_60051562)]
end






#Ab hier: Hell & Warm (Forstenried)
Fabricator :easymeter_60051595, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051595'
  registers [Fabricate.build(:register_60051595)]
end

Fabricator :easymeter_60051547, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051547'
  registers [Fabricate.build(:register_60051547)]
end

Fabricator :easymeter_60051620, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051620'
  registers [Fabricate.build(:register_60051620)]
end

Fabricator :easymeter_60051602, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051602'
  registers [Fabricate.build(:register_60051602)]
end

Fabricator :easymeter_60051618, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051618'
  registers [Fabricate.build(:register_60051618)]
end

Fabricator :easymeter_60051557, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051557'
  registers [Fabricate.build(:register_60051557)]
end

Fabricator :easymeter_60051596, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051596'
  registers [Fabricate.build(:register_60051596)]
end

Fabricator :easymeter_60051558, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051558'
  registers [Fabricate.build(:register_60051558)]
end

Fabricator :easymeter_60051551, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051551'
  registers [Fabricate.build(:register_60051551)]
end

Fabricator :easymeter_60051619, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051619'
  registers [Fabricate.build(:register_60051619)]
end

Fabricator :easymeter_60051556, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051556'
  registers [Fabricate.build(:register_60051556)]
end

Fabricator :easymeter_60051617, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051617'
  registers [Fabricate.build(:register_60051617)]
end

Fabricator :easymeter_60051555, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051555'
  registers [Fabricate.build(:register_60051555)]
end

Fabricator :easymeter_60051616, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051616'
  registers [Fabricate.build(:register_60051616)]
end

Fabricator :easymeter_60051615, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051615'
  registers [Fabricate.build(:register_60051615)]
end

Fabricator :easymeter_60051546, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051546'
  registers [Fabricate.build(:register_60051546)]
end

Fabricator :easymeter_60051553, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051553'
  registers [Fabricate.build(:register_60051553)]
end

Fabricator :easymeter_60051601, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051601'
  registers [Fabricate.build(:register_60051601)]
end

Fabricator :easymeter_60051568, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051568'
  registers [Fabricate.build(:register_60051568)]
end

Fabricator :easymeter_60051610, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051610'
  registers [Fabricate.build(:register_60051610)]
end

Fabricator :easymeter_60051537, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051537'
  registers [Fabricate.build(:register_60051537)]
end

Fabricator :easymeter_60051564, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051564'
  registers [Fabricate.build(:register_60051564)]
end

Fabricator :easymeter_60051572, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051572'
  registers [Fabricate.build(:register_60051572)]
end

Fabricator :easymeter_60051552, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051552'
  registers [Fabricate.build(:register_60051552)]
end

Fabricator :easymeter_60051567, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051567'
  registers [Fabricate.build(:register_60051567)]
end

Fabricator :easymeter_60051586, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051586'
  registers [Fabricate.build(:register_60051586)]
end

Fabricator :easymeter_60051540, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051540'
  registers [Fabricate.build(:register_60051540)]
end

Fabricator :easymeter_60051578, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051578'
  registers [Fabricate.build(:register_60051578)]
end

Fabricator :easymeter_60051597, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051597'
  registers [Fabricate.build(:register_60051597)]
end

Fabricator :easymeter_60051541, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051541'
  registers [Fabricate.build(:register_60051541)]
end

Fabricator :easymeter_60051570, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051570'
  registers [Fabricate.build(:register_60051570)]
end

Fabricator :easymeter_60051548, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051548'
  registers [Fabricate.build(:register_60051548)]
end

Fabricator :easymeter_60051612, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051612'
  registers [Fabricate.build(:register_60051612)]
end

Fabricator :easymeter_60051549, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051549'
  registers [Fabricate.build(:register_60051549)]
end

Fabricator :easymeter_60051587, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051587'
  registers [Fabricate.build(:register_60051587)]
end

Fabricator :easymeter_60051566, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051566'
  registers [Fabricate.build(:register_60051566)]
end

Fabricator :easymeter_60051592, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051592'
  registers [Fabricate.build(:register_60051592)]
end

Fabricator :easymeter_60051580, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051580'
  registers [Fabricate.build(:register_60051580)]
end

Fabricator :easymeter_60051538, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051538'
  registers [Fabricate.build(:register_60051538)]
end

Fabricator :easymeter_60051590, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051590'
  registers [Fabricate.build(:register_60051590)]
end

Fabricator :easymeter_60051588, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051588'
  registers [Fabricate.build(:register_60051588)]
end

Fabricator :easymeter_60051543, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051543'
  registers [Fabricate.build(:register_60051543)]
end

Fabricator :easymeter_60051582, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051582'
  registers [Fabricate.build(:register_60051582)]
end

Fabricator :easymeter_60051539, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051539'
  registers [Fabricate.build(:register_60051539)]
end

Fabricator :easymeter_60051545, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051545'
  registers [Fabricate.build(:register_60051545)]
end

Fabricator :easymeter_60051614, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051614'
  registers [Fabricate.build(:register_60051614)]
end

Fabricator :easymeter_60051550, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051550'
  registers [Fabricate.build(:register_60051550)]
end

Fabricator :easymeter_60051573, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051573'
  registers [Fabricate.build(:register_60051573)]
end

Fabricator :easymeter_60051571, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051571'
  registers [Fabricate.build(:register_60051571)]
end

Fabricator :easymeter_60051544, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051544'
  registers [Fabricate.build(:register_60051544)]
end

Fabricator :easymeter_60051594, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051594'
  registers [Fabricate.build(:register_60051594)]
end

Fabricator :easymeter_60051583, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051583'
  registers [Fabricate.build(:register_60051583)]
end

Fabricator :easymeter_60051604, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051604'
  registers [Fabricate.build(:register_60051604)]
end

Fabricator :easymeter_60051593, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051593'
  registers [Fabricate.build(:register_60051593)]
end

Fabricator :easymeter_60051613, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051613'
  registers [Fabricate.build(:register_60051613)]
end

Fabricator :easymeter_60051611, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051611'
  registers [Fabricate.build(:register_60051611)]
end

Fabricator :easymeter_60051609, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051609'
  registers [Fabricate.build(:register_60051609)]
end

Fabricator :easymeter_60051554, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051554'
  registers [Fabricate.build(:register_60051554)]
end

Fabricator :easymeter_60051585, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051585'
  registers [Fabricate.build(:register_60051585)]
end

Fabricator :easymeter_60051621, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051621'
  registers [Fabricate.build(:register_60051621)]
end

Fabricator :easymeter_60051565, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051565'
  registers [Fabricate.build(:register_60051565)]
end

# Fabricator :easymeter_60051595, from: :easy_meter_q3d do
#  manufacturer_product_serialnumber   '60051562'
#  registers [Fabricate.build(:register_60051562)]
# end

Fabricator :easymeter_60051579, from: :easy_meter_q3d do
 manufacturer_product_serialnumber   '60051579'
 registers [Fabricate.build(:register_60051579)]
end

#third party supplied
Fabricator :easymeter_60051575, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60051575'
 registers [Fabricate.build(:register_60051575)]
end


#abgrenzung pv
Fabricator :easymeter_60009484, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009484'
  registers [Fabricate.build(:register_60009484)]
end

#bhkw1
Fabricator :easymeter_60138947, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60138947'
  registers [Fabricate.build(:register_60138947)]
end

#bhkw2
Fabricator :easymeter_60138943, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60138943'
  registers [Fabricate.build(:register_60138943)]
end

#pv
Fabricator :easymeter_1338000816, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '1338000816'
  registers [Fabricate.build(:register_1338000816)]
end

#schule
Fabricator :easymeter_60009485, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009485'
  registers [Fabricate.build(:register_60009485)]
end

#hst_mitte
Fabricator :easymeter_1338000818, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '1338000818'
  registers [Fabricate.build(:register_1338000818)]
end

#übergabe in out
Fabricator :easymeter_1305004864, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '1305004864'
  registers [Fabricate.build(:register_1305004864), Fabricate.build(:register_1305004864_out)]
end

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
  registers [Fabricate.build(:register_ferraris_001_amperix)]
end


### LCP Sulz ###

# ÜGZ
Fabricator :easymeter_60300856, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60300856'
  registers [Fabricate.build(:register_60300856), Fabricate.build(:register_60300856_out)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id, converter_constant: 20)
  end
end

# Abgrenzung BHKW
Fabricator :easymeter_60009498, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60009498'
  registers [Fabricate.build(:register_60009498)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

# Produktion BHKW
Fabricator :easymeter_60404855, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60404855'
  registers [Fabricate.build(:register_60404855)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

# Produktion PV
Fabricator :easymeter_60404845, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60404845'
  registers [Fabricate.build(:register_60404845)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

# Allgemeinstrom
Fabricator :easymeter_60404846, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60404846'
  registers [Fabricate.build(:register_60404846)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

Fabricator :easymeter_60404850, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60404850'
  registers [Fabricate.build(:register_60404850)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

Fabricator :easymeter_60404851, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60404851'
  registers [Fabricate.build(:register_60404851)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

Fabricator :easymeter_60404853, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60404853'
  registers [Fabricate.build(:register_60404853)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

Fabricator :easymeter_60404847, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60404847'
  registers [Fabricate.build(:register_60404847)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

Fabricator :easymeter_60327350, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60327350'
  registers [Fabricate.build(:register_60327350)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

Fabricator :easymeter_60404854, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60404854'
  registers [Fabricate.build(:register_60404854)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

Fabricator :easymeter_60404852, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60404852'
  registers [Fabricate.build(:register_60404852)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

Fabricator :easymeter_60404849, from: :easy_meter_q3d do
  manufacturer_product_serialnumber   '60404849'
  registers [Fabricate.build(:register_60404849)]
  after_create do |meter|
    Fabricate(:equipment, meter_id: meter.id)
  end
end

