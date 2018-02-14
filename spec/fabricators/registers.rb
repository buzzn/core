# ALL registers can only be used via Fabricate.build or with an extra meter: some_meter attribute, as a register can not exist without a meter

['input', 'output', 'virtual'].each do |klass_type|
  klass = "Register::#{klass_type.camelize}".constantize

  Fabricator "#{klass_type}_register", class_name: klass do
    metering_point_id { 'DE' + Random.new_seed.to_s.slice(0, 29) }
    direction   { klass_type == 'virtual' ? ['in', 'out'].sample : klass_type.sub('put', '') }
    created_at  { (rand*10).days.ago }
    if klass_type == 'output'
      label     Register::Base.labels[:production_pv]
    else
      label     Register::Base.labels[:consumption]
    end
    share_with_group true
    share_publicly false
    type { "Register::#{klass_type.camelize}" }
  end
end

# real world registers

Fabricator :register_z1a, from: :input_register do
  label Register::Base.labels[:grid_consumption]
end

Fabricator :register_z1b, from: :output_register do
  label Register::Base.labels[:grid_feeding]
end

Fabricator :register_z2, from: :output_register do
end

Fabricator :register_z3, from: :input_register do
end

Fabricator :register_z4, from: :output_register do
  label Register::Base.labels[:production_chp]
end

Fabricator :register_z5, from: :output_register do
  label Register::Base.labels[:demarcation_pv]
end

#felix berlin
Fabricator :register_urbanstr88, from: :input_register do
end

# karins pv anlage
Fabricator :register_pv_karin, from: :output_register do
  devices { [Fabricate(:pv_karin)] }
end

# stefans bhkw anlage
Fabricator :register_stefans_bhkw, from: :output_register do
  label Register::Base.labels[:production_chp]
end

# hof butenland windanlage
Fabricator :register_hof_butenland_wind, from: :output_register do
end

# christian_schuetze verbrauch
Fabricator :register_cs_1, from: :input_register do
end

# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :register_60138988, from: :input_register do
end

#Nr. 60232612 ist eigentlich Cohaus WA10 - N36 aber zu Testzwecken für kristian
Fabricator :register_kristian, from: :input_register do
end

# Nr. 60009269 für Philipp Oßwald (Einrichtungszähler Bezug)
Fabricator :register_60009269, from: :input_register do
end

# Nr. 60232499 für Thomas Theenhaus (Einrichtungszähler Bezug)
Fabricator :register_60232499, from: :input_register do
end

# Nr. 60232499 für Thomas Theenhaus (Einrichtungszähler Bezug)
Fabricator :register_ferraris_001_amperix, from: :input_register do
end

Fabricator :register_60118470, from: :output_register do
  label Register::Base.labels[:grid_consumption]
end

Fabricator :register_60009316, from: :output_register do
  label Register::Base.labels[:grid_feeding]
end

Fabricator :register_60009272, from: :input_register do
end

Fabricator :register_60009348, from: :input_register do
end

Fabricator :register_hdh, from: :virtual_register do
  direction 'in'
end

Fabricator :register_60009416, from: :input_register do
end

Fabricator :register_60009419, from: :input_register do
end

Fabricator :register_60009415, from: :input_register do
end

Fabricator :register_60009418, from: :input_register do
end

Fabricator :register_60009411, from: :input_register do
end

Fabricator :register_60009410, from: :input_register do
end

Fabricator :register_60009407, from: :input_register do
end

Fabricator :register_60009409, from: :input_register do
end

Fabricator :register_60009435, from: :input_register do
end

Fabricator :register_60009420, from: :input_register do
end

Fabricator :register_60118460, from: :output_register do
end

Fabricator :register_60009386, from: :input_register do
end

Fabricator :register_60009445, from: :input_register do
end

Fabricator :register_60009446, from: :input_register do
end

Fabricator :register_60009390, from: :input_register do
end

Fabricator :register_60009387, from: :input_register do
end

Fabricator :register_60009438, from: :input_register do
end

Fabricator :register_60009440, from: :input_register do
end

Fabricator :register_60009404, from: :input_register do
end

Fabricator :register_60009405, from: :input_register do
end

Fabricator :register_60009422, from: :input_register do
end

Fabricator :register_60009425, from: :input_register do
end

Fabricator :register_60009402, from: :input_register do
end

Fabricator :register_60009429, from: :input_register do
end

Fabricator :register_60009393, from: :input_register do
end

Fabricator :register_60009442, from: :input_register do
end

Fabricator :register_60009441, from: :input_register do
end

Fabricator :register_60118484, from: :input_register do
  label Register::Base.labels[:grid_consumption]
end

Fabricator :register_60051562, from: :input_register do
end

#Ab hier: Hell & Warm (Forstenried)
Fabricator :register_60051595, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051547, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051620, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051602, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051618, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051557, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051596, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051558, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051551, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051619, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051556, from: :input_register do
  label     Register::Base.labels[:consumption]
end

Fabricator :register_60051617, from: :input_register do
end

Fabricator :register_60051555, from: :input_register do
end

Fabricator :register_60051616, from: :input_register do
end

Fabricator :register_60051615, from: :input_register do
end

Fabricator :register_60051546, from: :input_register do
end

#andreas kapfer
Fabricator :register_60051553, from: :input_register do
end

Fabricator :register_60051601, from: :input_register do
end

Fabricator :register_60051568, from: :input_register do
end

Fabricator :register_60051610, from: :input_register do
end

Fabricator :register_60051537, from: :input_register do
end

Fabricator :register_60051564, from: :input_register do
end

Fabricator :register_60051572, from: :input_register do
end

Fabricator :register_60051552, from: :input_register do
end

Fabricator :register_60051567, from: :input_register do
end

Fabricator :register_60051586, from: :input_register do
end

Fabricator :register_60051540, from: :input_register do
end

Fabricator :register_60051578, from: :input_register do
end

Fabricator :register_60051597, from: :input_register do
end

Fabricator :register_60051541, from: :input_register do
end

Fabricator :register_60051570, from: :input_register do
end

Fabricator :register_60051548, from: :input_register do
end

Fabricator :register_60051612, from: :input_register do
end

Fabricator :register_60051549, from: :input_register do
end

Fabricator :register_60051587, from: :input_register do
end

Fabricator :register_60051566, from: :input_register do
end

Fabricator :register_60051592, from: :input_register do
end

Fabricator :register_60051580, from: :input_register do
end

Fabricator :register_60051538, from: :input_register do
end

Fabricator :register_60051590, from: :input_register do
end

Fabricator :register_60051588, from: :input_register do
end

Fabricator :register_60051543, from: :input_register do
  #meter {  Fabricate(:easymeter_60051543) }
end

Fabricator :register_60051582, from: :input_register do
  #meter {  Fabricate(:easymeter_60051582) }
end

Fabricator :register_60051539, from: :input_register do
  #meter {  Fabricate(:easymeter_60051539) }
end

Fabricator :register_60051545, from: :input_register do
  #meter {  Fabricate(:easymeter_60051545) }
end

Fabricator :register_60051614, from: :input_register do
  #meter {  Fabricate(:easymeter_60051614) }
end

Fabricator :register_60051550, from: :input_register do
  #meter {  Fabricate(:easymeter_60051550) }
end

Fabricator :register_60051573, from: :input_register do
  #meter {  Fabricate(:easymeter_60051573) }
end

Fabricator :register_60051571, from: :input_register do
  #meter {  Fabricate(:easymeter_60051571) }
end

Fabricator :register_60051544, from: :input_register do
  #meter {  Fabricate(:easymeter_60051544) }
end

Fabricator :register_60051594, from: :input_register do
  #meter {  Fabricate(:easymeter_60051594) }
end

Fabricator :register_60051583, from: :input_register do
  #meter {  Fabricate(:easymeter_60051583) }
end

Fabricator :register_60051604, from: :input_register do
  #meter {  Fabricate(:easymeter_60051604) }
end

Fabricator :register_60051593, from: :input_register do
  #meter {  Fabricate(:easymeter_60051593) }
end

Fabricator :register_60051613, from: :input_register do
  #meter {  Fabricate(:easymeter_60051613) }
end

Fabricator :register_60051611, from: :input_register do
  #meter {  Fabricate(:easymeter_60051611) }
end

Fabricator :register_60051609, from: :input_register do
  #meter {  Fabricate(:easymeter_60051609) }
end

Fabricator :register_60051554, from: :input_register do
end

Fabricator :register_60051585, from: :input_register do
end

Fabricator :register_60051621, from: :input_register do
end

Fabricator :register_60051565, from: :input_register do
end

Fabricator :register_60051579, from: :input_register do
  label Register::Base.labels[:consumption]
end

#third party supplied
Fabricator :register_60051575, from: :input_register do
  label Register::Base.labels[:consumption]
end

#abgrenzung pv
Fabricator :register_60009484, from: :output_register do
  label Register::Base.labels[:demarcation_pv]
end

#bhkw1
Fabricator :register_60138947, from: :output_register do
  label Register::Base.labels[:production_chp]
end

#bhkw2
Fabricator :register_60138943, from: :output_register do
  label Register::Base.labels[:production_chp]
end

#pv
Fabricator :register_1338000816, from: :output_register do
  label Register::Base.labels[:production_pv]
end

#schule
Fabricator :register_60009485, from: :input_register do
  label Register::Base.labels[:consumption]
end

#hst_mitte
Fabricator :register_1338000818, from: :input_register do
  label Register::Base.labels[:consumption]
end

#übergabe in
Fabricator :register_1305004864, from: :input_register do
  label Register::Base.labels[:grid_consumption]
end

#übergabe out
Fabricator :register_1305004864_out, from: :output_register do
  label Register::Base.labels[:grid_feeding]
end

#virtueller Zählpunkt
Fabricator :register_forstenried_erzeugung, from: :output_register do
  meter           nil
  virtual         true
  formula_parts   do [
                    Fabricate(:fp_plus, operand_id: Fabricate(:register_60138947).id),
                    Fabricate(:fp_plus, operand_id: Fabricate(:register_60138943).id),
                    Fabricate(:fp_minus, operand_id: Fabricate(:register_1338000816).id)
                  ] end
end

#virtueller Zählpunkt
Fabricator :register_forstenried_bezug, from: :input_register do
  virtual true
end

### LCP Sulz ###

#übergabe in
Fabricator :register_60300856, from: :input_register do
  label Register::Base.labels[:grid_consumption]
  metering_point_id 'DE0005128238000552109002001011500'
end

#übergabe out
Fabricator :register_60300856_out, from: :output_register do
  label Register::Base.labels[:grid_feeding]
  metering_point_id 'DE0005128238000552109002001011500'
end

#Abgrenzung bhkw
Fabricator :register_60009498, from: :output_register do
  label Register::Base.labels[:demarcation_chp]
  metering_point_id 'DE0005128238000552109002001011400'
end

#Produktion bhkw
Fabricator :register_60404855, from: :output_register do
  label Register::Base.labels[:production_chp]
  metering_point_id 'DE0005128238000552109002001011200'
end

#Produktion pv
Fabricator :register_60404845, from: :output_register do
  label Register::Base.labels[:production_pv]
  metering_point_id 'DE0005128238000552109002001011100'
end

Fabricator :register_60404846, from: :input_register do
  label Register::Base.labels[:consumption]
end

Fabricator :register_60404850, from: :input_register do
  label Register::Base.labels[:consumption]
end

Fabricator :register_60404851, from: :input_register do
  label Register::Base.labels[:consumption]
end

Fabricator :register_60404853, from: :input_register do
  label Register::Base.labels[:consumption]
end

Fabricator :register_60404847, from: :input_register do
  label Register::Base.labels[:consumption]
end

Fabricator :register_60327350, from: :input_register do
  label Register::Base.labels[:consumption]
end

Fabricator :register_60404854, from: :input_register do
  label Register::Base.labels[:consumption]
end

Fabricator :register_60404852, from: :input_register do
  label Register::Base.labels[:consumption]
end

Fabricator :register_60404849, from: :input_register do
  label Register::Base.labels[:other]
end
