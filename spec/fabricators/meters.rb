Fabricator :meter do
  i = 1
  manufacturer_name           'Elster'
  manufacturer_product_name    'AS 1440'
  manufacturer_product_serialnumber   {3353984 + (i += 1)}
  registers                    { [Fabricate(:register_in)] }
end


Fabricator :in_meter, from: :meter do
  registers { [Fabricate(:register_in)] }
end

Fabricator :out_meter, from: :meter do
  registers { [Fabricate(:register_out)] }
end

Fabricator :in_out_meter, from: :meter do
  registers { [Fabricate(:register_in), Fabricate(:register_out)] }
end



# Justus easymeter fur verbrauch
Fabricator :easymeter_1124001747, from: :meter do
  manufacturer_name           'Easymeter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '1124001747'
  registers                    { [Fabricate(:register_in)] }
  equipments                   { [Fabricate(:equipment)] }
end

# Stefan easymeter fur verbrauch
Fabricator :easymeter_1024000034, from: :meter do
  manufacturer_name           'Easymeter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '1024000034'
  registers                    { [Fabricate(:register_out)] }
  equipments                   { [Fabricate(:equipment)] }
end


# karins meter fur die pv anlange
Fabricator :easymeter_60051431, from: :meter do
  manufacturer_name           'Easymeter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '60051431'
  registers                    { [Fabricate(:register_out)] }
  equipments                   { [Fabricate(:equipment)] }
end




# Z0 für PV-Anlage
# Fabricator :easymeter_60118470, from: :meter do
#   manufacturer_name                   'Easymeter'
#   manufacturer_product_name           'Q3D'
#   manufacturer_product_serialnumber   '60118470'
#   registers                           { [Fabricate(:register_in), Fabricate(:register_out)] }
#   equipments                          { [Fabricate(:equipment)] }
# end

# Z1  Nr. 60118470 für Hans-Dieter Hopf  (Zweirichtungszähler)
Fabricator :easymeter_60118470, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60118470'
  registers                           { [Fabricate(:register_in), Fabricate(:register_out)] }
  equipments                          { [Fabricate(:equipment)] }
end

# Z2   Nr. 60009316 für BHKW Erzeugung (Einrichtungszähler Einspeisung)
Fabricator :easymeter_60009316, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009316'
  registers                           { [Fabricate(:register_out)] }
  equipments                          { [Fabricate(:equipment)] }
end

# ZN1 Nr. 60009272 für Thomas Hopf  (Einrichtungszähler Bezug)
Fabricator :easymeter_60009272, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009272'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end

# ZN2 Nr. 60009348 für Mauela Beier (Einrichtungszähler Bezug)
Fabricator :easymeter_60009348, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009348'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end




# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :easymeter_60138988, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60138988'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end


# Nr. 60009269 für Philipp Oßwald (Einrichtungszähler Bezug)
Fabricator :easymeter_60009269, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009269'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end

# Meter für virtuellen MP für Hopf
Fabricator :virtual_meter_hopf, from: :meter do
  manufacturer_name                   ''
  manufacturer_product_name           ''
  manufacturer_product_serialnumber   '123456'
  registers                           { [Fabricate(:register_in, virtual: true, formula: "44-43+42-39-38")] }
end



# wagnis 4
Fabricator :easymeter_60009416, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009416'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
# wagnis 4
Fabricator :easymeter_60009419, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009419'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
# wagnis 4
Fabricator :easymeter_60009415, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009415'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
# wagnis 4
Fabricator :easymeter_60009418, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009418'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
# wagnis 4
Fabricator :easymeter_60009411, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009411'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
# wagnis 4
Fabricator :easymeter_60009410, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009410'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
# wagnis 4
Fabricator :easymeter_60009407, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009407'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
# wagnis 4
Fabricator :easymeter_60009409, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009409'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
# wagnis 4
Fabricator :easymeter_60009435, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009435'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
# wagnis 4
Fabricator :easymeter_60009420, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009420'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
# Wagnis 4 PV
Fabricator :easymeter_60118460, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60118460'
  registers                           { [Fabricate(:register_out)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Allgemeinstrom Haus Nord
Fabricator :easymeter_60009386, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009386'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Allgemeinstrom Haus Ost
Fabricator :easymeter_60009445, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009445'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Gäste Haus Ost 1+2
Fabricator :easymeter_60009446, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009446'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Laden EG
Fabricator :easymeter_60009390, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009390'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Nord Wohnung 01
Fabricator :easymeter_60009387, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009387'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Nord Wohnung 10
Fabricator :easymeter_60009438, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009438'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Nord Wohnung 12
Fabricator :easymeter_60009440, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009440'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Nord Wohnung 15
Fabricator :easymeter_60009404, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009404'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Nord Wohnung 17
Fabricator :easymeter_60009405, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '600093405'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Nord Wohnung 18
Fabricator :easymeter_60009422, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009422'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Nord Wohnung 19
Fabricator :easymeter_60009425, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009425'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Nord Wohnung 20
Fabricator :easymeter_60009402, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009402'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Ost 03
Fabricator :easymeter_60009429, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009429'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Ost Wohnung 12
Fabricator :easymeter_60009393, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009393'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Ost Wohnung 13
Fabricator :easymeter_60009442, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009442'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Ost Wohnung 15
Fabricator :easymeter_60009441, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009441'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
#Wagnis 4 - Übergabe
Fabricator :easymeter_60118484, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60118484'
  registers                           { [Fabricate(:register_in), Fabricate(:register_out)] }
  equipments                          { [Fabricate(:equipment)] }
end







# Pickel
Fabricator :easymeter_60051562, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60051562'
  registers                           { [Fabricate(:register_out)] }
  equipments                          { [Fabricate(:equipment)] }
end




















