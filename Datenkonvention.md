# Edfu Daten 

## Datenquellen

### Formular.xsl
* Tabellenblatt:
* Ausbau:

...


### Beispielhafte Imagemap: Pylon.html
* Aufbau
	* Liste von area-Tags 
	* Felder:
		* shape: {poly | rect}
		* coords: je nach shape, 2-Punkt oder mehrere-Punkte
		* title: <Titel> - Edfou <Band>, p. <page>, (pl. <plate>)
		* alt: wie title

### Aus Imagemap generierte CSV-Datei: 
* Aufbau pylon.csvdescription;volume;page;plate;polygon;link;angleOfView;coord-x;coord-y;height-percent;extent-width;extent-height-percent

### ... (Bilddatei)
* ...


## Beschreibung/Definition 

* Reihenfolge jeweils wie in den Tabellen.

### Formulare

* **TEXTMITSUF**: Transliteration mit Suffix
* **BAND**: Publikationsband 
	* Gäste dürfen zur Zeit nur die Bände 7 und 8 einsehen
* **SEITEZEILE**: Seite und Zeile des Datensatzes im Band
* **TEXTOHNSU**: Transliteration ohne Suffix 
	* Dieses Textfeld sollte bei Gästen nicht angezeigt werden
	* Anzeige ansonsten unterhalb von TEXTMITSUF. 
* **TEXTDEUTSC**: Deutsche Übersetzung. 
	* Anzeige unterhalb von TEXTMITSUF bzw. TEXTOHNESU.
* **TEXTTYP**: Szenentyp
* **Photo**: Photoauflistung. 
	* Wird anhand des Kommadelimiters aufgetrennt um einzelne Photos zu ermitteln. 
	* Wenn vorhanden (z.B. Photo D03_225 = D03_225.jpg), dann Link erstellen.
* **SzenenID**: Zur eindeutigen Identifizierung einer Szene.
	* Eine Szene kann aus mehreren Datensätzen bestehen. 
* **SekLit**: Sekundärliteratur.
* **UniqueID**: Eindeutige Datensatznummer für evtl. Indizierung.


### Orte

* **STELLE**: Stelle
* **TRANS**: Transliteration des Ortsnamens
* **ORT**: Übersetzung des Ortsnamens
* **LOK**: Lokalisation
* **ANM**: Anmerkung
* **UniqueId**:

### Götter

* **PRIMARY**:
* **NAME**: Bezeichnung/Name des Gottes
* **ORT**: Heimatkultort
* **EPON**: Epitheta / Personifikation
* **BEZ**: Beziehung
* **FKT**: Funktion des Gottes
* **BND**: Publikationsband
* **SEITEZEILE**: Seite und Zeile des Datensatzes im Band
* **ANM**: Etwaige Anmerkungen
* **UniqueID**: Eindeutige Datensatznummer zur Indizierung

## Wörter

* **Lemma**: Transliteration des Wortes
* **deutsch**: Übersetzung des Wortes
* **IDS**: Eindeutige ID auf eine Graphik, welche die Hieroglyphengruppe zeigt 
	* z.B. 2666 = 2666.emf
	* Besagte Graphik wird bei Aufruf geladen
* **Weiteres**: Transliterierte Anmerkungen
* **BelegstellenEdfu**: Edfu Belegstelle
* **BelegstellenWb**: Wörterbuch Belegstelle
* **Anmerkung**: Deutschsprachige Anmerkungen

## Wb-Berlin

*


## Konvention/Interpretation

### Formulate

### Orte

### Götter

* Stelle mit ff. am Ende: 
	* Zeilestop unsicher 

### Wörter

## Beziehungen

* Formular-Stelle 
	* Ein Formular ist mit (i.d.R. nur) einer Stelle Verbunden
* Ort-Stelle 
	* Orte sind ggf. mit 
* Gott-Stelle 
	* 
* Wort-Stelle 
	* 

* Wort-

* Stelle-Szene
	* Eine Stelle kann mit beliebig vielen Szenen verbunden sein (*).
	* Eine Szene kann mit beliebig vielen Stellen verbunden sein (*).


## Welche Felder (Solr) werden tatsächlich für das FE benötigt?
