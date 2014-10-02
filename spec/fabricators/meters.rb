Fabricator :meter do
  i = 1
  manufacturer_name           'Elster'
  manufacturer_product_name    'AS 1440'
  manufacturer_product_serialnumber   {3353984 + (i += 1)}
  virtual                      false
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




# Nr. 60009348 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :easymeter_60138988, from: :meter do
  manufacturer_name                   'Easymeter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60138988'
  registers                           { [Fabricate(:register_in)] }
  equipments                          { [Fabricate(:equipment)] }
end
















