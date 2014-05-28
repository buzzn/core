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

## Metering Point

Der Metering Point ist ein Messpunkt in einer Messtelle, also z.B. der Messpunkt des Einspeisezählers, der des Bezugzählers oder der des Übergabezählers. 

|Value|Type|Example|Explanation
|:----|:---|:------|:----------
|Mode|String|Up|
|Voltage|Int|230|230 V
