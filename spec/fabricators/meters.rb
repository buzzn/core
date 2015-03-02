Fabricator :meter do
  i = 1
  manufacturer_name           'ferraris'
  manufacturer_product_name    'AS 1440'
  manufacturer_product_serialnumber   {3353984 + (i += 1)}
end

Fabricator :urbanstr88_meter, from: :meter do
  image { File.new(Rails.root.join('db', 'seed_assets', 'meters', 'urbanstr88', '1.jpg' )) }
  manufacturer_product_name           'CG11'
  manufacturer_product_serialnumber   '08053883'
end




# Justus Übergabe
Fabricator :easymeter_60139082, from: :meter do
  manufacturer_name           'easy_meter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '60139082'
end

# Justus PV
Fabricator :easymeter_60051599, from: :meter do
  manufacturer_name           'easy_meter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '60051599'
end

# Justus Ladestation
Fabricator :easymeter_60051559, from: :meter do
  manufacturer_name           'easy_meter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '60051559'
end

# Justus BHKW
Fabricator :easymeter_60051560, from: :meter do
  manufacturer_name           'easy_meter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '60051560'
end


# Justus Abgrenzung
Fabricator :easymeter_60051600, from: :meter do
  manufacturer_name           'easy_meter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '60051600'
end

# Justus verbrauch
Fabricator :easymeter_1124001747, from: :meter do
  manufacturer_name           'easy_meter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '1124001747'
end




# Stefan easymeter fur verbrauch
Fabricator :easymeter_1024000034, from: :meter do
  manufacturer_name           'easy_meter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '1024000034'
end


# karins meter fur die pv anlange
Fabricator :easymeter_60051431, from: :meter do
  manufacturer_name           'easy_meter'
  manufacturer_product_name   'Q3D'
  manufacturer_product_serialnumber  '60051431'
end




# Z1  Nr. 60118470 für Hans-Dieter Hopf  (Zweirichtungszähler)
Fabricator :easymeter_60118470, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60118470'
end

# Z2   Nr. 60009316 für BHKW Erzeugung (Einrichtungszähler Einspeisung)
Fabricator :easymeter_60009316, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009316'
end

# ZN1 Nr. 60009272 für Thomas Hopf  (Einrichtungszähler Bezug)
Fabricator :easymeter_60009272, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009272'
end

# ZN2 Nr. 60009348 für Mauela Beier (Einrichtungszähler Bezug)
Fabricator :easymeter_60009348, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009348'
end




# Nr. 60138988 für Christian Widmann (Einrichtungszähler Bezug)
Fabricator :easymeter_60138988, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60138988'
end


# Nr. 60009269 für Philipp Oßwald (Einrichtungszähler Bezug)
Fabricator :easymeter_60009269, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009269'
end

# Meter für virtuellen MP für Hopf
Fabricator :virtual_meter_hopf, from: :meter do
  manufacturer_name                   ''
  manufacturer_product_name           ''
  manufacturer_product_serialnumber   '123456'
end



# wagnis 4
Fabricator :easymeter_60009416, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009416'
end
# wagnis 4
Fabricator :easymeter_60009419, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009419'
end
# wagnis 4
Fabricator :easymeter_60009415, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009415'
end
# wagnis 4
Fabricator :easymeter_60009418, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009418'
end
# wagnis 4
Fabricator :easymeter_60009411, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009411'
end
# wagnis 4
Fabricator :easymeter_60009410, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009410'
end
# wagnis 4
Fabricator :easymeter_60009407, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009407'

end
# wagnis 4
Fabricator :easymeter_60009409, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009409'
end
# wagnis 4
Fabricator :easymeter_60009435, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009435'
end
# wagnis 4
Fabricator :easymeter_60009420, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009420'
end
# Wagnis 4 PV
Fabricator :easymeter_60118460, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60118460'
end
#Wagnis 4 - Allgemeinstrom Haus Nord
Fabricator :easymeter_60009386, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009386'
end
#Wagnis 4 - Allgemeinstrom Haus Ost
Fabricator :easymeter_60009445, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009445'
end
#Wagnis 4 - Gäste Haus Ost 1+2
Fabricator :easymeter_60009446, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009446'
end
#Wagnis 4 - Laden EG
Fabricator :easymeter_60009390, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009390'
end
#Wagnis 4 - Nord Wohnung 01
Fabricator :easymeter_60009387, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009387'
end
#Wagnis 4 - Nord Wohnung 10
Fabricator :easymeter_60009438, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009438'
end
#Wagnis 4 - Nord Wohnung 12
Fabricator :easymeter_60009440, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009440'
end
#Wagnis 4 - Nord Wohnung 15
Fabricator :easymeter_60009404, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009404'
end
#Wagnis 4 - Nord Wohnung 17
Fabricator :easymeter_60009405, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '600093405'
end
#Wagnis 4 - Nord Wohnung 18
Fabricator :easymeter_60009422, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009422'
end
#Wagnis 4 - Nord Wohnung 19
Fabricator :easymeter_60009425, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009425'
end
#Wagnis 4 - Nord Wohnung 20
Fabricator :easymeter_60009402, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009402'
end
#Wagnis 4 - Ost 03
Fabricator :easymeter_60009429, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009429'
end
#Wagnis 4 - Ost Wohnung 12
Fabricator :easymeter_60009393, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009393'
end
#Wagnis 4 - Ost Wohnung 13
Fabricator :easymeter_60009442, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009442'
end
#Wagnis 4 - Ost Wohnung 15
Fabricator :easymeter_60009441, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60009441'
end
#Wagnis 4 - Übergabe
Fabricator :easymeter_60118484, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60118484'
end





# Pickel
Fabricator :easymeter_60051562, from: :meter do
  manufacturer_name                   'easy_meter'
  manufacturer_product_name           'Q3D'
  manufacturer_product_serialnumber   '60051562'
end




















