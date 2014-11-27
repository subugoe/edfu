class Wort < ActiveRecord::Base
  has_one :wb_berlin
  has_many :stellen, as: :zugehoerigZu

  # after_update :log_updated
  # after_create :log_created
  before_validation :check_data

  searchable do

    integer :uid, stored: true
    text :transliteration, stored: true # todo transliteration_highlight hinzufügen
    text :transliteration_nosuffix, stored: true
    text :uebersetzung, stored: true
    text :hieroglyph, stored: true
    text :weiteres, stored: true
    text :belegstellenEdfu, stored: true # todo in was indexiert? stelle_id?
    text :belegstellenWb, stored: true   # todo in was indexiert? stelle_berlin_id?
    text :anmerkung, stored: true
    # todo stelle_id und attr. aus Stelle hinzufügen, und bandseitezeile_highlight hinzufügen
    # todo id hinzufügen, typ hinzufügen,
    # todo attr. aus Szene hinzufügen
    # todo felder prüfen

  end


  private

  def check_data

    check_belegstellen_re1

  end


  # todo in ein Modul packen und in Modell-Klassen wiederverwenden
  def self.update_or_create(attributes)
    assign_or_new(attributes).save
  end

  # todo in ein Modul packen und in Modell-Klassen wiederverwenden
  def self.assign_or_new(attributes)
    obj = first || new
    obj.assign_attributes(attributes)
    obj
  end


  # todo update solr doc
  # todo log updated
  def log_updated
    logger.info "[INFO]  after update: #{id}"
  end


  # todo add doc to solr
  # todo log created
  def log_created

    logger.info "[INFO]  before save: #{id}"

  end


  def check_belegstellen_re1

    # find in python liefert index, priüfen ob das überall korrekt übertragen wurde

# Tabelle WL

    re20 = Regexp.new('^\s*([VI]*)\s*,?\s*(<?)([0-9]*)\s*,\s*([0-9/ -]*)(>?\*?)\s*(.*)$')


      anmerkungWL = ''

      bEdfu = self[:belegstellenEdfu]

      if bEdfu.index('zum Beispiel') == 0
          # 1266, 1296, 2781, 2811
          bEdfu = bEdfu.replace('zum Beispiel', '')
      anmerkungWL = '(Beispiele) '
      elsif bEdfu.index('<VIII, ') == 0
          # 732, 797, 804, 816, 2247, 2312, 2319, 2331
          bEdfu = 'VIII, <' + bEdfu[7..-1]
      elsif bEdfu == 'E VIII, 0,31, 07; 060, 07'
          # 1089, 2604
          bEdfu = 'E VIII, 031, 07; 060, 07'
      elsif bEdfu == 'E VIII, 033, 01; 068, 02; 098, 02; 103; 18; 162, 05'
          # 1415, 2930
          bEdfu = 'E VIII, 033, 01; 068, 02; 098, 02; 103, 18; 162, 05'
      elsif bEdfu == 'E VIII, 026, 07; 041, 05; 053, 06; 156,l 15'
          # 1491
          bEdfu = 'E VIII, 026, 07; 041, 05; 053, 06; 156, 15'
          end

          # .match(/(^\s*,\s*)(.*)(\s*,\s*$)/)[2]
      #bEdfu = bEdfu.strip('EPON; ')
          bEdfu = bEdfu.match(/(^EPON; )(.*)(EPON; $)/)[2]

      # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
          bEdfu = bEdfu.gsub(/ \/ V/, '; V')

      if self[:belegstellenEdfu] != bEdfu
          logger.info "\t[INFO]  [GL] uid: #{self[:uid]} Änderung BelegstellenEdfu, original: #{self[:belegstellenEdfu]} new: #{bEdfu}"
      end

      wb = self[:belegstellenWb]
      wbID = nil
      anmerkungWB = nil
      notiz = nil

      if wb == 'nicht im Wb belegt'
          wbID = 0
      elsif wb.length > 0
          if wb == 'nach II, 123, 12 - 124*'
              wb = 'nach II, 123, 12 - 124, 1'
          anmerkungWB = '*'
          elsif wb == 'I, 171, 03 - 12; 18 - 21'
              # 356
              wb = 'I, 171, 03 - 12'
          elsif wb == 'II, 429 - 432, 05'
              # 1358-1361
              wb = 'II, 429, 01 - 432, 05'
          elsif wb == 'II, 498 - 500, 24'
              # 1418-1420
              wb = 'II, 498, 01 - 500, 24'
          elsif wb == 'III, 026 - 027, 19'
              # 1441
              wb = 'III, 026,01 - 027, 19'
          end

          if wb != self[:belegstellenWb]
              anmerkungWB = 'ursprünglich: ' + self[:belegstellenWb]
              logger.info "\t[INFO]  [GL] uid: #{self[:uid]} Änderung BelegstellenWb, original: #{self[:belegstellenWb]} new: #{wb}"
          end



          vornach = 0
          if wb.find('nach ') == 0
              vornach = 1
          wb = wb.replace('nach ', '')
          elsif wb.find('vor ') == 0
              vornach = -1
          wb = wb.replace('vor ', '')

          end


          roemischBand = wb[0..wb.index(',')]

          wb = wb[wb.index(',') + 1:].strip()

      end

          band = roemisch[roemischBand]

          wb = wb.replace(' -', '-').replace('- ', '-')

          if wb.find('-') != -1
              # Range
              teile = wb.split('-')
          if len(teile) == 2
              seiteZeile = teile[0].split(',')
          seiteStart = int(seiteZeile[0].strip())
          seiteStop = seiteStart
          try:
              zeileStart = int(seiteZeile[1].strip())
          except ValueError, IndexError:
              print "FEHLER: WL " + str(PRIMARY) + ": Datensatz mit Beleg " + seiteZeile[0] + u" überprüfen"
          except IndexError:
                     print "FEHLER: WL " + str(PRIMARY) + ": Datensatz mit Beleg " + seiteZeile[0] + u" überprüfen"

          if teile[1].find(',') != -1:
              # Komma im zweiten Teil: unterschiedliche Seiten
              seiteZeile2 = teile[1].split(',')
          seiteStop = int(seiteZeile2[0].strip())
          zeileStop = int(seiteZeile2[1].strip())
          else:
              # Range innerhalb einer Seite
              zeileStop = int(teile[1].strip())

          start = [seiteStart, zeileStart]
          stop = [seiteStart, zeileStop]

          else:
              print "\t".join(["WL", str(PRIMARY), "FEHLER", u"BelegstellenWb Formatfehler", BelegstellenWb, wb])

          else:
              # Nur eine Stelle
              try:
              start = szSplit(wb)
          except IndexError, ValueError:
              print "FEHLER: WL " + str(PRIMARY) + ": Stelle " + wb + " konnte nicht gesplittet werden"
          stop = start

          myWB = {
              'uid': len(berlin),
              'band': band,
              'seite_start': start[0],
              'seite_stop': stop[0],
              'zeile_start': start[1],
              'zeile_stop': stop[1],
              'vornach': vornach,
              'notiz': notiz,
              'anmerkung': anmerkungWB
          }

          bereitsVorhanden = False
          for b in berlin:
            if b['seite_start'] == myWB['seite_start'] and b['seite_stop'] == myWB['seite_stop'] and b['zeile_start'] == \
                myWB['zeile_start'] and b['zeile_stop'] == myWB['zeile_stop'] and b['notiz'] == myWB['notiz'] and b[
                'anmerkung'] == myWB['anmerkung']:
                myWB['uid'] = b['uid']
            bereitsVorhanden = True

            if not bereitsVorhanden:
                berlin += [myWB]
            wbID = myWB['uid']

            myWort = {
                'uid': PRIMARY,
                'id': PRIMARY,
                'transliteration': Transliteration,
                'weiteres': Weiteres,
                'uebersetzung': Deutsch,
                'anmerkung': (anmerkungWL + Anmerkungen).strip(),
                'hieroglyph': IDS,
                'lemma': None,
                'wb_berlin_uid': wbID
            }

# wird unter der Tabelle WORT hinzugefügt
            wort += [myWort]

            bandNr = 0
            seiteStart = 0
            zerstoerung = False

            if len(bEdfu) > 0:
                belegstellen = bEdfu.split(';')
            for b in belegstellen:
              b = b.strip()

              klammer = False
              stern = False

              if b.find('%') != -1:
                  zerstoerung = True
              b = b.replace('%', '').replace('&', '')

              if b.find(',') == -1:
                  if seiteStart != 0:
                      b = str(seiteStart) + ', ' + b
                  #					print "\t".join(["WL", str(PRIMARY), "INFO", u"Seitenzahl hinzugefügt", b])
                  else:
                      print "\t".join(["WL", str(PRIMARY), "FEHLER", u"keine Seitenzahl", b])

                  m20 = re20.match(b)
                  if m20:
                      if len(m20.group(1)) > 0:
                          bandNr = roemisch[m20.group(1).strip()]
                      elif bandNr == 0:
                          print "\t".join(["WL", str(PRIMARY), "FEHLER", u"fehlende Bandangabe", b])

                      seiteStart = int(m20.group(3))
                      seiteStop = seiteStart
                      anmerkung = ''

                      if m20.group(4).find(' - ') != -1:
                          zeileStart = int(m20.group(4).split(' - ')[0])
                      zeileStop = int(m20.group(4).split(' - ')[1])
                      else:
                          zeilenString = m20.group(4)
                      zeilenString = zeilenString.replace('/', '-').replace(' ', '')
                      zeilen = zeilenString.split('-')
                      if len(zeilen) == 1:
                          zeileStart = int(zeilen[0])
                      zeileStop = zeileStart
                      elif len(zeilen) == 2:
                          zeileStart = int(zeilen[0])
                      zeileStop = int(zeilen[1])
                      else:
                          print "\t".join(["WL", str(PRIMARY), "FEHLER", u"zu viele Komponenten in Zeilenangabe", b])

                      anmerkung = m20.group(6).strip()

                      if m20.group(5) == '>':
                          klammer = True
                      elif m20.group(5) == '>*':
                          stern = True
                      elif len(m20.group(5)) > 2:
                          print "\t".join(["WL", str(PRIMARY), "FEHLER", u"m20.group(5) zu lang", b])

                      myStelle = {
                          'uid': len(stelle),
                          'band_uid': bandNr,
                          'seite_start': seiteStart,
                          'seite_stop': seiteStop,
                          'zeile_start': zeileStart,
                          'zeile_stop': zeileStop,
                          'anmerkung': anmerkung,
                          'stop_unsicher': False,
                          'zerstoerung': zerstoerung
                      }
                      stelle += [myStelle]

                      if myStelle['zeile_start'] > 30:
                          print "\t".join(["WL", str(PRIMARY), "FEHLER", "zeile_start > 30", b])
                      if myStelle['zeile_stop'] > 30:
                          print "\t".join(["WL", str(PRIMARY), "FEHLER", "zeile_stop > 30", b])

                      wort_has_stelle += [{
                                              'uid_local': PRIMARY,
                          'uid_foreign': myStelle['uid'],
                          'schreiber_verbessert': klammer,
                          'chassinat_verbessert': stern
                      }]

                      else:
                          print "\t".join(["WL", str(PRIMARY), "FEHLER", u"keine erkennbare Seitenzahl", b])


                      end


end
