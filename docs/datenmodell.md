# Datenmodell

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
|title|String|Miss, Ms, Mr, Sir, Mrs, Dr| Anrede
|first_name|String|
|last_name|String|
|phone|String|
|gender|String| male, female, other
|know_buzzn_from|Text|
|newsletter_notifications|Boolean|
|meter_notifications|Boolean|
|group_notifications|Boolean|

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
