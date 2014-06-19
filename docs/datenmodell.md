# Datenmodell

[ER Diagramt (lucidchart)](http://www.lucidchart.com/invitations/accept/63ba51e0-d86f-40c3-960c-3920d931eba3)

Examples die in [eckige klammern] zusammengefasst sind.
sind die einzigen werte die gesetzt werden können.





## User
Jeder Benutzer muss sich bevor er mit der buzzn app interagieren kann anmelden.
benötigt wird dabei seine email addresse, password und das akzeptieren der nutzungsbedingungen(terms)

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|email|String|mail@ffaerber.com
|terms|Boolean||nutzungsbedingungen





## Profile

im Profil werden die eigentlichen Benutzer Daten gespeichert.

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|image|String||der link zum bild
|title|String|[miss, dr]| Anreden
|first_name|String|Felix
|last_name|String|Faerber
|phone|String|+49 173 893 43 43
|gender|String| [male, female, other]|
|know_buzzn_from|Text| Habe euch im Fernsehen bei quer gesehen.
|newsletter_notifications|Boolean| ob user generelle buzzn email newsletter bekommen möchte.
|location_notifications|Boolean| ob user über veränderungen und nachrichten in einer location informiert werden möchte
|group_notifications|Boolean| ob user über veränderungen und nachrichten in einer group informiert werden möchte




## Location

Eine Location ist eine Ansammlung von "Metering Points"

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|name|String|Urbanstrasse 88|
|slug|String|urbanstrasse-88| http://www.buzzn.net/locations/urbanstrasse-88
|image|String|/locations/images/13132.jpg| ein bild von der location. zumbeispiel haus oder wohnung
|new_habitation|Boolean|[true,false]| ob der user dort neu einziehen wird.
|inhabited_since|Date|1.5.2014| Seit wann der user die location bewohnt
|active|Boolean|[true,false]| ob die location aktiv ist





## Metering Point

Der Metering Point ist ein Messpunkt in einer Messtelle, also z.B. der Messpunkt des Einspeisezählers, der des Bezugzählers oder der des Übergabezählers.

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|uid|string|DE12356458478STROM236874565231459|Zählpunkt-iD mi 33 Stellen
|mode|String|[up,down,up_down,diff]| beschreibt die stromrichtung die gemessen wird
|Adress addition|String|2. Stock links| Die genaue location des Metering Point
|voltage_level|string|[low, medium, high, highest]| spannung ebende. meistens low
|regular_reeding|date|15.4.2014|geplante Turnusablesung
|regular_interval|string|[monthly, annually, quarterly, half_yearly]| in welchem interwall abgelesen wird




## Group

eine group ist eine ansamlung von down_metering_points die von einem up_metering_point strom beziehen.
User können um aufname ihres down_metering_point in die grupe bitten. der group admin kann diese dann hinzufügen oder ablehnen(wenn der geografische abstand zu gross ist von up zu down_metering_point).

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|slug|String|vegan-buchenhain| slug vom namen
|name|String|Vegan Buchenhain|name der Gruppe
|private|String|false|ob die gruppe privat ist oder öffenlich einsehbar
|description|String|Strom von Veganer für veganer|kleine strory zur gruppe




## Device

Das Device ist ein Gerät, das Strom benötigt oder Strom herstellt. Die meisten Anwender werden Devices haben die Strom benötigen z.B. Kühlschrank, Kaffeemaschine, Herd oder Lampen. Es kann aber auch eine Photovoltaikanlage oder ein BHKW sein.

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|image|String|path_to_image|Bild von Herd
|name|String|Herd|
|mode|string|[up, down, up_down]| Erzeuger oder Verbraucher oder beides(electrospeicher)
|law|string|[eeg, kwkg]|Nur für Stromerzeuger.
|generator_type|string|XRGI 15|Nur für Stromerzeuger. Modell
|manufacturer_product_number|string|12364ABC585|Herstellernummer
|primary_energy|string|[gas, oil, lpg, sun, wind, water, bio]|Primärenergie.
|watt_peak|int|2000|Ganze Zahl, Einheit Wp
|watt_hour_pa|int|380000|Ganze Zahl, Einheit Wh
|commisioning_date|date|23.05.2010|Inbetriebnahmedatum
|mobile|Boolean|[true,false]| ob das gerät mobil verwendet werden kann. wie Elektroauto.
|comments|text|Lampe von meiner Oma|Kommentar






## Meter

Das Meter ist ein Messgerät, dass Menge und Leistung eines Mediums erfasst. Bei uns wird es Strom sein.

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|manufacturer_name|string|Hager 0815|Hersteller
|manufacturer_product_number|string|AS 1440| Herstellernummer
|manufacturer_device_number|string|12345DAS789| Zählernummer
|owner|string|[ownership, foreign_ownership, leased, sold]|Besitzstatus
|metering_type|string|[ahz, vsz, laz, ehz, edl40, edl21, maz, iva]|Zählertyp gruppen. meistens ahz
|rate|string|[etz, ztz, ntz]|Tarif. Kann folgende Werte annehmen: ETZ - Eintarif, ZTZ - Zweitarif, NTZ - Mehrtarif
|mode|string|[up,down,up_down]| Richtung
|measurement_capture|string|[amr,mmr]|Messwerterfassung. Kann folgende Werte annehmen: AMR - fernauslesbare Zähler, MMR - manuell ausgelesene Zähler
|mounting_method|string|[bkw, dpa]|Befestigungsart. BKW - Stecktechnik, DPA - 3-Punktaufhängung
|build_year|Date|1.1.2012|Baujahr
|calibrated_till|Date|1.1.2018|Geeicht bis
|virtual|Boolean||ob der Zähler errechnet wird.





## Equipment

Das Equipment sind Zusatzgeräte die den Zähler in iregnd einer Weise unterstützen. Bsp. Funkrunsteuergeräte oder Wandlersatz

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|device_kind|string|[z25,z26,z27]|Geräteart. Z25 - Wandler / Mengenumwandler, Z26 - Kommunikationseinrichtung, Z27 - techn. Steuereinrichtung
|device_type|string|wiw| Gerätetyp.
|owner|string|[ownership, foreign_ownership, leased, sold]|Besitzstatus
|build|Date|31.12.2012|Baujahr
|calibrated_till|Date|31.12.2017|Geeicht bis
|manufacturer_name|string|Bosch| Herstellername
|manufacturer_product_number|string|X3000| Herstellernummer
|manufacturer_device_number|string|1234DAS789345345345|Geräte Seriennummer
|converter_constant|integer|40| Wandlerkonstante




## Register

Das Register ist ein Zählwerk. Ein Zähler kann mehrere Zählwerke besitzen, die mehrere Werte erfassen. Strommenge, Spitzenleistung, Blindleistung oder Spannung

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|obis_index|string|1-1:8.0|Obiskennzahl
|variable_tariff|Boolean|[true,false]| ob Pauschaltarif oder variablertarif(schwachlastfähig), default: false
|mode|string|[up,down]| Richtung
|predecimal_places|int|8| Vorkommastellen
|decimal_places|int|2| Nachkommastellen




## Reading

Reading sind aus den regiustern ausgelesene Werte die in einer Zeitreihe gespeichert werden

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|datetime|datetime|01.01.2012-23:15:01|Ablesezeitpunkt, Sekundengenau
|reason|string|Turnusablesung|Ablesegrund. Kann folgende Werte annehmen: Turnusablesung, Zwischenablesung, Gerätewechsel, Geräteeinbau, Geräteausbau, Geräteparameteränderung, Vertragswechsel, Bilanzierungsgebietswechsel
|quality|string|[phone, email, fax, webform, electic, dso, other]|Qualität der Ablesung.
|state|string|Z86|Status (z86 abgelesener und kontrolierter wert)
|watt_hour|int|265436|Messwert
|load_course_time_series|Decimal|0,00236|Lastgang


## iln

marktpartner information

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|bdew|integer|9910435673000|13 stellen
|eic|string|9sd8fg9sdfg98dfg|
|vnb|string|sg9ds8fg9sdfg89|
|valid_begin|date|1.1.2013|
|valid_end|date|31.12.2017|



## Organization

Organizationen jeder art werden in einem Organization objekt gespeichert.
einige mögliche Organizationen typen sind, electricity_supplier metering_service_provider, distribution_system_operator und mehr

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|image|string|/organization/312/logo.jpg|
|name|string|E.ON|
|email|string|info@eon.com|
|phone|string|0800 12345678|
|fax|string|0800 12345679|
|description|string|E.ON mit Sitz in Düsseldorf ist weltweit eines der größten privaten Strom- und Gasunternehmen.|
|website|string|www.eon.com|
|mode|string|[electricity_supplier, metering_point_operator, ...]|






