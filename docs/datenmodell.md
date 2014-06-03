# Datenmodell

[ER Diagramt (lucidchart)](http://www.lucidchart.com/invitations/accept/63ba51e0-d86f-40c3-960c-3920d931eba3)

Examples die in einem array zusammengefasst sind. sind die einzigen werte die gesetzt werden können.

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
|image|String|
|title|String|[miss, dr]| Anreden
|first_name|String|Felix
|last_name|String|Faerber
|phone|String|+49 173 893 43 43
|gender|String| [male, female, other]|
|know_buzzn_from|Text| Habe euch im Fernsehen bei quer gesehen.
|newsletter_notifications|Boolean| ob user generelle buzzn email news bekommen möchte
|location_notifications|Boolean| ob user über veränderungen und nachrichten in einer location informiert werden möchte
|group_notifications|Boolean| ob user über veränderungen und nachrichten in einer group informiert werden möchte

## Location

Eine Location ist eine Ansammlung von "Metering Points"

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|slug|||

## Metering Point

Der Metering Point ist ein Messpunkt in einer Messtelle, also z.B. der Messpunkt des Einspeisezählers, der des Bezugzählers oder der des Übergabezählers.

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|uid|string|DE12356458478STROM236874565231459|Zählpunkt-iD mi 33 Stellen
|Mode|String|Up|
|Adress addition|String|2. Stock links
|Voltage|string|low_voltage|4 mögliche Werte: low_voltage, medium_voltage, high_voltage, highest_voltage
|regular_reeding|date|0115|geplante Turnusablesung, Format MMDD
|regular_interval|string|anually|4 mögliche werte: monthly, annually, quarterly, half-yearly

## Device

Das Device ist ein Gerät, das Strom benötigt oder Strom herstellt. Die meisten Anwender werden Devices haben die Strom benötigen z.B. Kühlschrank, Kaffeemaschine, Herd oder Lampen. Es kann aber auch eine Photovoltaikanlage oder ein BHKW sein.

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|image|image|Bild von Herd|Bild
|name|string|Herd|
|type|string|up|Erzeuger oder Verbraucher. Mögliche Werte: up, down, up/down
|law|string|EEG|Nur für Stromerzeuger. Mögliche Werte: EEG, KWKG, frei, "leer"
|generator_type|string|XRGI 15|Nur für Stromerzeuger. Modell
|Manufacturer_product_number|string|12364ABC585|Herstellernummer
|primary_energy|string|Erdgas|Primärenergie. Mögliche Werte: Erdgas, Heizöl, Flüssiggas, Sonne, Wind, Wasser, Biogas, Holz, Pflanzenöl, Biomasse, sonstige
|watt_peak|int|2000|Ganze Zahl, Einheit Wp
|watt_hour_pa|int|380000|Ganze Zahl, Einheit Wh
|commisioning_date|date|23.05.2010|Inbetriebnahmedatum
|comments|text|Lampe von meiner Oma|Kommentar

## Meter

Das Meter ist ein Messgerät, dass Menge und Leistung eines Mediums erfasst. Bei uns wird es Strom sein.

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|manufacturer_name|string|Hager 0815|Hersteller
|manufacturer_product_number|string|12345DAS789| Herstellernummer
|manufacturer_meter_number|string|12345DAS789| Zählernummer
|ownership|string|Eigentum|Besitzstatus: Kann folgende 4 Werte annehmen: Eigentum, Fremdbesitz, verpachtet, verkauft
|meter_type|string|AHZ|Zählertyp. Kann folgende Werte annehmen: AHZ, VSZ, LAZ, EHZ, MAZ, IVA
|meter_size|string|Z03-sonstiger EHZ|Kann folgende Werte annehmen: Z01-EDL40, Z02-EDL21, Z03-sonstiger EHZ
|rate|string|ETZ|Tarif. Kann folgende Werte annehmen: ETZ - Eintarif, ZTZ - Zweitarif, NTZ - Mehrtarif
|direction|string|ERZ|Richtung. Kann folgende Werte annehmen: ERZ - Einrichtungszähler, ZRZ - Zweirichtungszähler
|measurement_capture|string|AMR - fernauslesbare Zähler|Messwerterfassung. Kann folgende Werte annehmen: AMR - fernauslesbare Zähler, MMR - manuell ausgelesene Zähler
|mounting_method|string|BKW - Stecktechnik|Befestigungsart. BKW - Stecktechnik, DPA - 3-Punktaufhängung
|build_year|int|2012|Baujahr
|calibrated_till|int|2018|Geeicht bis

## Equipment

Das Equipment sind Zusatzgeräte die den Zähler in iregnd einer Weise unterstützen. Bsp. Funkrunsteuergeräte oder Wandlersatz

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|device_number|string|1234DAS789|Gerätenummer
|ownership|string|Eigentum|Besitzstatus: Kann folgende 4 Werte annehmen: Eigentum, Fremdbesitz, verpachtet, verkauft
|device_kind|string|Z25 - Wandler / Mengenumwandler|Geräteart. Kann folgende Werte annehmen: Z25 - Wandler / Mengenumwandler, Z26 - Kommunikationseinrichtung, Z27 - techn. Steuereinrichtung
|device_type|string|WIW - Messwandlersatz Strom|Gerätetyp.
|build_year|stringint|2012|Baujahr
|calibrated_till|int|2018|Geeicht bis
|manufacturer_product_number|string|12345DAS789| Herstellernummer
|device_number|string|1234DAS789|Gerätenummer
|converter_constant|int|40|Wandlerkonstante

## Register

Das Register ist ein Zählwerk. Ein Zähler kann mehrere Zählwerke besitzen, die mehrere Werte erfassen. Strommenge, Spitzenleistung, Blindleistung oder Spannung

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|obis_index|string|1-1:8.0|Obiskennzahl
|low_load_able|string|ZNS - nicht schwachlastfähig|Schwachlastfähig. Kann folgende Werte annehmen: ZNS - nicht schwachlastfähig, ZSF - Scwachlastfähig
|tagging|string|Bezug|Gerätenummer
|pre_decimal_point_position|int|8|Vorkommastellen
|decimal_place|int|2|Nachkommastellen

## Reading

Reading sind aus den regiustern ausgelesene Werte die in einer Zeitreihe gespeichert werden

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|datetime|datetime|01.01.2012-23:15:01|Ablesezeitpunkt, Sekundengenau
|reason|string|Turnusablesung|Ablesegrund. Kann folgende Werte annehmen: Turnusablesung, Zwischenablesung, Gerätewechsel, Geräteeinbau, Geräteausbau, Geräteparameteränderung, Vertragswechsel, Bilanzierungsgebietswechsel
|quality|string|220|Qualität der Ablesung. Kann folgende Werte annehmen: Telefon, Email, Fax, Internetformular, Netzbetreiber, elektronisch, andere
|Wh|int|265436|Messwert
|load_course_time_series|real|0,00236|Lastgang
|state|string|Z86|Status


