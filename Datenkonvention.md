# Edfu Daten 

## Datenquellen, Definition und Konvention

### Formular.xsl (Formular)
* Tabellenblatt: 
	* Position: 1. Blatt
	* Name: Tabelle1
* Tabellenspalten
	* **TEXTMITSUF, BAND, SEITEZEILE, TEXTOHNESU, TEXTDETSC, TEXTTYP, Photo, SzeneID, SekLit, UniqueID**

###### Beschreibung/Definition 

* **TEXTMITSUF**: 
	* Transliteration mit Suffix
	* Text
* **BAND**: 
	* Publikationsband 
	* Zahl (1 - 8)
	* Gäste dürfen zur Zeit nur die Bände 7 und 8 einsehen
* **SEITEZEILE**: 
	* Seite und Zeile des Datensatzes im Band
	* Referenziert zugehörige Stellen im Chassinat-Band
	* Formularen sind immer genau mit einer Stelle verbunden
	* Aufbau
		* Seite, Zeile
	* Text
	* Muster (Beispiele)
		* **nach 251, 15**
			* <span style="color: red">nach?</span>
			* <span style="color: red">Seite 251, Zeile 15</span>
		* **001, 11-12**
			* <span style="color: red">Seite 1, Zeile 11-12</span>
		* **001, 12 - 002, 01**
			* <span style="color: red">Seite 1, Zeile 12 - Seite 2, Zeile 1</span>
		* **003, 02**
			* <span style="color: red">Seite 3, Zeile 2</span>
		* **130, 01 / kol. 03**
			* <span style="color: red">Seite 130, Zeile 1</span>
			* <span style="color: red">Was bedeutet '/ kol. 03'?</span>
		* **354, 11 / 030, 09**
			* <span style="color: red">Interpretation?</span>
		* **354, 11-12 / 030, 09-10**
			* <span style="color: red">Interpretation?</span>
		* **355, 01-02 / (Kommentar: 030, 12-13)**
			* <span style="color: red">Was bedeutet '/ (...)'? Interpretation?</span>
		* **176, 1-7, Z.1**
			* <span style="color: red">Seite 176, Zeile 1-7</span>
			* <span style="color: red">'Z. 1' weist auf sehr rare Fälle hin, in denen Zeile 1 zu berücksichtigen ist. Der Fall ist ähnlich gelagert wie die Hinweise auf Zeilen mit zusätzlichen Informationen z.B. (30), aber dennoch etwas anders. Hier handelt es sich um eine interne Konvention.</span>
		* **176, 1-7, Z.9-13**
			* <span style="color: red">Seite 176, Zeilen 1-7</span>
			* <span style="color: red">Z. 9-13 wie zuvor, d.h. seltene Fälle, in denen Zeilen 9-13 zu verwenden sind?</span>
		* **nach 146, 09, Z.01**
* **TEXTOHNSU**: 
	* Transliteration ohne Suffix 
	* Text
	* Dieses Textfeld sollte bei Gästen nicht angezeigt werden
	* Anzeige ansonsten unterhalb von TEXTMITSUF. 
* **TEXTDEUTSC**: 
	* Deutsche Übersetzung. 
	* Text
	* Anzeige unterhalb von TEXTMITSUF bzw. TEXTOHNESU.
* **TEXTTYP**: 
	* Szenentyp
	* Text
	* <span style="color: red">Position im Tempel?</span>
* **Photo**: 
	* Komma separierte Auflistung einzelner Photos.
	* Text
	* Wenn vorhanden (z.B. Photo D03_225 = D03_225.jpg), dann Link erstellen.
		* <span style="color: red">d.h. prüfen, ob Bild im Dateisystem vorhanden ist, nur Link erstellen, wenn Bild vorhanden</span>
	* Muster (Beispiele)
		* **1546 oder 1908a**
			* Typ=SW, Name=1546, Pfad=SW/1546
			* Typ=SW, Name=1908a, Pfad=SW/1908a
			* reg. Expr. /^[0-9]+a*/
	
	 	* **e073**
			* Typ=e, Name=e073, Pfad=e/e073
			* reg. Expr. /^e[0-9]+/
		* **E. XIV, pl. DCLV oder E. XIV, pl. DLIII, DLIV oder E. XIII, pl. DXV, DXVI, DXVII**
			* Typ=Edfou XIV, Name=pl. DCLV, Pfad=Edfou XIV/pl. DCLV
			* reg. Expr. /^(E. [XVI]+), ([pl. ]*[DCLXVI0-9]+)/
			* <span style="color: red">pl. DCLV steht für Platenummer</span>
			* <span style="color: red">Fotos, die als Plates in einem Chassinat-Band vorliegen. Ein Plate ist eine Bildseite. Diese kann mehrere Grafiken enthalten.</span>
			* <span style="color: red">Dateinamen enthalten ggf. Leerzeichen?</span>
		* **D05_6680 oder D03_0693**
			* Typ=2005, Name=D0_6680, Pfad=2005/D0_6680
			* reg. Expr. /^D05_[0-9]+a*/
			* Typ=2003, Name=D0_0693, Pfad=2003/D0_0693
			* reg. Expr. /^D03_[0-9]+/
		* **G3 oder G32 ff.**
			* Typ=G, Name=G32, Pfad=G/G32
			* reg. Expr. /^(G[0-9]+)\s*([f.]*)/	
			* <span style="color: red">Bedeutung von ff. ? Gehört ff. zum Namen?</span>
		* **Labrique Stylistique, pl. 11**
			* Typ=Labrique, Stylistique, Name=pl. 11, Pfad=Labrique, Stylistique/pl. 11
			* reg. Expr. /^;*\s*Labrique, Stylistique, (pl. [0-9.]*)/
		* **e-onr-1**
			* Typ=e-o, Name=e-onr-1, Pfad=e-o/e-onr-1
			* reg. Expr. /^e-onr-[0-9]+/
* **SzenenID**: 
	* Zur eindeutigen Identifizierung einer Szene.
	* Zahl (derzeit nur für wenige Datensätze)
* **SekLit**: 
	* Sekundärliteratur.
	* Text (derzeit nur für wenige Datensätze)
* **UniqueID**: 
	* Eindeutige Datensatznummer für evtl. Identifizierung.
	* Zahl, fortlaufend


### Topo.xsl (Ort)
* Tabellenblatt: 
	* Position: 1. Blatt
	* Name: Tabelle1
* Tabellenspalten
	* **STELLE, TRANS, ORT, LOK, ANM, UniqueID**

###### Beschreibung/Definition 

* **STELLE**: 
	* Semikolon separierte Auflistung einzelner Stellen.
 	* Referenziert zugehörige Stellen im Chassinat-Band.
	* Orte können mit mehreren Stellen verbunden sein.
	* Aufbau
		* Band (römisch), Seite und Zeile des Datensatzes im Band.
	* Text
	* Muster (Beispiele)
		* **VI, 32, 5; **
			* <span style="color: red">Band 6, Seite 32, Zeile 5</span>
		* **VI, 43, 4/5; **
			* <span style="color: red">Band 6, Seite 43, Zeile 4 und 5</span>
		* **V, 227, 17 - 228, 1; **
			* <span style="color: red">Band 5, Seite 227, Zeile 17 - Seite 228, Zeile 1</span>
		* **VII, 10, 7; 33, 18; 34, 12; 182, 7; 269, 14; V, 255, 15; **
		* **VII, 183, 15 ([]); **
			* <span style="color: red">[] bedeutet, die Stelle ist zerstört, kann aber als sicher angesehen werden.</span>
		* **V, 35, 8; 145, 17 ([]?); **
			* <span style="color: red">([] ?)  - wie zuvor?</span>
		* **VII, 22, 10 ([ ]); 256, 1; VI, 14, 3; 108, 3; 280, 8; V, 172, 13 ([]); **
			* <span style="color: red">([ ])  - wie zuvor?</span>
		* **VII, 185, 7/8 (?); **
			* <span style="color: red">(?) ?</span>
		* **V, 31, 5; 40, 14; 42, 5 (<>); 94, 14; **
			* <span style="color: red"><> bedeutet, die Stelle muß korrigiert werden, weil dem Ägypter (Schreiber) ein Fehler unterlaufen ist.</span>
		* **V, 302, 16 (<  >); **
			* <span style="color: red">(<  >) - wie zuvor?</span>
		* **V, 355, 7 (<Smaj>); **
			* <span style="color: red">Interpretation?</span>
		* **VI, 90, 3 (30); 209, 13; **
			* <span style="color: red">(30) weist auf zusätzliche Information in Zeile 30 hin, es handelt sich aber nicht um einen zweite Fall.</span>
		* **VI, 36, 11; 208, Anm. 2; 328, 17/18; **
			* <span style="color: red">Anmerkung 2 betrifft gesamte Seite 208</span>
		* **V, 174, 2; 182, 12; 183, 11 (Tempel: Det.:  ); 199, 5; 245, 12; 248, 11; 255, 12 (Det.:  ); 261, 10 (dito); 313, 11 (dito); **
		* **VIII, 76, 8 (die Bewohner); V, 25, 10/11 ([R?]Tnw) **
			* <span style="color: red">?</span>
		* **VII, 184, 13; 283, 12 (s. Anmerkung) VI, 275, 2; **
		* **VII, 240, 2 (2x); **
			* <span style="color: red">?</span>
		* **V, 42, 2 ("¦A-Fnxw"); 143, 5; **
		* **VII, 264, 13; 276, 16 (--nw--); **
		* **V, 132, 3 (Halle des Lebens); 135, 9; **
		* **VIII, 53, 2; 61, 13; 62, 1 (konjiziert); 75, 6; 75, 7/8; **
		* **VIII, 134, 17; 137, 15; 140, 10 (sic); 141, 9 ( ); **
		* **VII, 23, 7; 24, 4; 31, 11 (Hnwt nwwt); 33, 13 (nb wTst); 43, 8; 58, 4 (  (sic)); **
		* **V, 4, 1; 5, 4; 6, 7; 8, 8; 8, 9; 11, 5; 29, 2 ([...?);  **
			* <span style="color: red">?</span>
		* **VIII, 64, 8; V, 221, 1 ([?]-xpr); 274, 6 (dito); **
			* <span style="color: red">Bedeutung/Zusatzinformation?</span>
		 		* ([]), ([ ]), ([]?), ([R?]Tnw), ([?]-xpr)
			 	* (<>), (< >), (<Smaj>)
			 	* (2x), ("¦A-Fnxw"), (--nw--), (  (sic))
* **TRANS**: 
	* Transliteration des Ortsnamens
	* Text
* **ORT**: 
	* Übersetzung des Ortsnamens
	* Text
* **LOK**: 
	* Lokalisation
	* Text
* **ANM**: 
	* Anmerkung
	* Text
	* nur teilweise belegt
* **UniqueId**:
	* Eindeutige Datensatznummer für evtl. Identifizierung.
	* Zahl, fortlaufend


### Gods.xsl (Gott)
* Tabellenblatt: 
	* Position: 1. Blatt
	* Name: Tabelle1
* Tabellenspalten
	* **PRIMARY, NAME, ORT, EPON, BEZ, FKT, BND, SEITEZEILE, ANM, UniqueID**

###### Beschreibung/Definition 

* **PRIMARY**:
	* Eindeutige Datensatznummer  für evtl. Identifizierung
	* Zahl, fortlaufend
* **NAME**: 
	* Bezeichnung/Name des Gottes
	* Text
* **ORT**: 
	* Heimatkultort
	* Text
	* nur teilweise belegt
* **EPON**: 
	* Epitheta / Personifikation
	* Text
	* nur teilweise belegt
* **BEZ**: 
	* Beziehung
	* Text
* **FKT**: 
	* Funktion des Gottes
	* Text
* **BND**: 
	* Publikationsband
	* römische Ziffer (I - VIII)
* **SEITEZEILE**: 
	* Referenziert zugehörige Stellen
		* Seite und Zeile des Datensatzes im Band
	* Text
	* i.d.R. konkreter Bereich, selten Semikolon separierte Auflistung einzelner Stellen.
	* mit f. am Ende bedeutet plus folgende Zeile
	* mit ff. am Ende bedeutet der Zeilenstop ist unsicher (mehrere folgezeilen)
	* Muster (Beispiele)
		* **078, 002; **
			* <span style="color: red">Seite 78, Zeile 2 ?</span>
		* **2,7? **
			* <span style="color: red">?</span>
		* **132, 013; 256, 10; **
			* <span style="color: red">Seite 132, Zeile 13; ...</span>
		* **119, 010 - 014; **
			* <span style="color: red">Seite 119, Zeile 10 - 14</span>
		* **120, 004ff.; **
			* <span style="color: red">ff steht für Stop unsicher, d.h. mehrere folgende Zeilen</span>
		* **187, 8 f. **
			* <span style="color: red">f steht für und die folgende Zeile</span>
			* <span style="color: red">Seite 187, Zeile 8 - 9?</span>
		* **009, 006/007; **
			* <span style="color: red">Zeile 6 und 7?</span>
		* **084, 015 - 085, 001; **
			* <span style="color: red">Seite 84, Zeile 15 - Seite 85, Zeile 1</span>
		* **021, 007/022, 001; **
			* <span style="color: red">Seite 21, Zeile 7 bis Seite 22, Zeile 1 ?</span>
		* **215, 11 (2x)-216, 1 (1 **
			* <span style="color: red">Bedeutung/Interpretation?</span>
* **ANM**: 
	* Etwaige Anmerkungen
	* Text
	* nur teilweise belegt
* **UniqueID**: 
	* Eindeutige Datensatznummer  für evtl. Identifizierung
	* Zahl, fortlaufend
	* identisch mit PRIMARY

### Woerterliste.xsl (Wort)
* Tabellenblatt: 
	* Position: 2. Blatt
	* Name: Tabelle1
* Tabellenspalten
	* **Lemma, deutsch, IDS, Weiteres, BelegstelleEdfu, BelegstelleWb, Anmerkung**

###### Beschreibung/Definition 

* **Lemma**: 
	* Transliteration des Wortes
	* Text
* **deutsch**: 
	* Übersetzung des Wortes
	* Text
* **IDS**: 
	* Eindeutige ID auf eine Graphik, welche die Hieroglyphengruppe zeigt 
		* z.B. 2666 = 2666.emf
	* meist Zahl, manchmal mit *Suffix* **A**
		* z.B. 54A, 60A
	* Besagte Graphik wird bei Aufruf geladen
* **Weiteres**: 
	* Transliterierte Anmerkungen
	* selten belegt
* **BelegstellenEdfu**: 
	* Referenziert zugehörige (Edfu) Stellen
		* Band (römisch), Seite und Zeile des Datensatzes im Band
	* Text
	* Semikolon separierte Auflistung einzelner Stellen.
	* Muster (Beispiele)
		* **VII, 046, 08 **
			* <span style="color: red">Band 7, Seite 46, Zeile 8?</span>
		* **VII, 018, 02; 018, 08; **
		* **VII, <097, 05>* **
			* <span style="color: red">Band 7, Seite 97, Zeile 5?</span>
			* <span style="color: red"><> - bedeutet, die Stelle muß korrigiert werden, weil dem Ägypter (Schreiber)  ein Fehler unterlaufen ist</span>
			* <span style="color: red">* - bedeutet, die Stelle muß korrigiert werden, weil dem Chassinat hier ein Fehler unterlaufen ist</span>
		* **VIII, 124, 01; VII, 161, 07 **
		* **VIII, 140, 02 - 03; 140, 15 **
		* **VIII, 077, 06 f.; 081, 13 **
			* <span style="color: red">Band 8, Seite 77, Zeile 6 - 7?</span>
		* **VIII, <012, 08>\*; <056, 12>\* **
* **BelegstellenWb**: 
	* Referenziert zugehörige (Wörterbuch) Stellen
		* Band (römisch), Seite und Zeile des Datensatzes im Wörterbuch
	* Text
	* jeweils ein konkreter Bereich, keine Auflistung.
	* Muster (Beispiele)
		* **I, 046 - 047, 03**
			* <span style="color: red">Seite 46 - 47</span>
			* <span style="color: red">Ziffer nach dem Komma bezeichnet keine Zeile, sondern eine Schreibung - was bedeutet das?</span>
		* **I, 001, 02 - 07 **
		* **I, 003, 12 - 004, 09 **
		* **I, 005, 03 **
		* **nach I, 008, 01 - 02 **
			* <span style="color: red">nach?</span>
		* **nach I, 020, 14 **
		* **nach I, 067, 13 - 068, 7 **
		* **I, 170, 03 - 12; 18 - 21 **
			* <span style="color: red">mehrere Bereiche auf der Seite?</span>
		* 
* **Anmerkung**: 
	* Deutschsprachige Anmerkungen
	* Text
	* nur teilweise belegt



### Beispielhafte Imagemap: (z.B. Pylon.html)
* Aufbau
	* Liste von area-Tags 
	* Felder:
		* shape: {poly | rect}
		* coords: je nach shape, 2-Punkt oder mehrere-Punkte
		* title: <Titel> - Edfou <Band>, p. <page>, (pl. <plate>)
		* alt: wie title

### Aus Imagemap generierte CSV-Datei:  (z.B. pylon.csv)
* Aufbau 
	* **description;volume;page;plate;polygon;link;angleOfView;coord-x;coord-y;height-percent;extent-width;extent-height-percent**

### ... (Bilddatei)
* ...

###### Beschreibung/Definition 

## Beziehungen


* Formular-Stelle 
	* Ein Formular ist (i.d.R. nur) mit einer Stelle (bzw. Bereich) verbunden
* Ort-Stelle 
	* Orte sind ggf. mit verschiedenen Stellen verbunden.
* Gott-Stelle 
	* Götter sind i.d.R. mit einer Stelle (bzw.  Bereich) verbunden, äußerst selten mit mehreren Stellen.
* Wort-Stelle 
	* Wörter sind ggf. mit verschiedenen Edfu Belegstellen verbunden, und mit einer Wörterbuch Belegstelle (bzw.  Bereich).

* Stelle-Szene
	* Eine Stelle kann mit beliebig vielen Szenen verbunden sein.
	* Eine Szene kann mit beliebig vielen Stellen verbunden sein.
	* Das Mapping von Stelle auf Szene erfolgt per Band und Startseite



## Offene Fragen? 
* Welche Felder (Solr) werden tatsächlich für das FE benötigt?
