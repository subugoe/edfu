class Gott < ActiveRecord::Base
  has_many :stellen, as: :zugehoerigZu


  # after_update :log_updated
  # after_create :log_created
  before_validation :check_data


  searchable do

    integer :uid, stored: true
    text :transliteration, stored: true # todo transliteration_highlight hinzufügen
    text :transliteration_nosuffix, stored: true
    text :ort, stored: true
    text :eponym, stored: true
    text :beziehung, stored: true
    text :funktion, stored: true
    integer :band, stored: true
    text :seitezeile, stored: true # todo wirklich in den index?
    text :anmerkung, stored: true
    # todo stelle_id und attr. aus Stelle hinzufügen, und bandseitezeile_highlight hinzufügen
    # todo id hinzufügen, typ hinzufügen,

  end


  private


  def check_data

    check_seitezeile_re_1

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

  def check_seitezeile_re_1


    gott = []
    gott_has_stelle = []

    # Tabelle GL

    re3 = Regexp.new(r '^\s*([VI]*)\s*,*\s*([0-9]*)\s*,\s*([0-9/ -]*)\s*(.*)$')


    originalSEITEZEILE = self[:seitenzeile]
    stelleAnmerkung = ''

    if self[:seitenzeile] == '066, 011ff,;'
      # 84
      self[:seitenzeile] = '066, 011ff'
    elsif self[:seitenzeile] == '264-269;'
      # 1551
      self[:seitenzeile] = '264, 0 - 269, 30;'
    elsif self[:seitenzeile] == '2,7?'
      # 1178
      self[:seitenzeile] = '2, 7'
      stelleAnmerkung = '2,7?'
    elsif self[:seitenzeile] == '052, 006 und 008;'
      # 2376
      self[:seitenzeile] = '052, 6-8'
    elsif self[:seitenzeile] == '215, 11 (2x)-216, 1 (1'
      # 2463
      self[:seitenzeile] = '215, 11 - 216, 1'
    elsif self[:seitenzeile] == '159'
      # 3266
      self[:seitenzeile] = '159, 0'
    elsif self[:seitenzeile] == '149, 3:'
      # 3654
      self[:seitenzeile] = '149, 3'
    elsif self[:seitenzeile] == '90, 3 (25);'
      # 4093
      self[:seitenzeile] = '90, 3;'
      stelleAnmerkung = '(25)'
    elsif self[:seitenzeile] == '39, 11/f.'
      # 5487
      self[:seitenzeile] = '39, 11f.'
    elsif self[:seitenzeile] == '90,3 (36)'
      # 5758
      self[:seitenzeile] = '90,3'
      stelleAnmerkung = '(36)'
    elsif self[:seitenzeile] == '33,14 33,14'
      # 5791
      self[:seitenzeile] = '33, 14'
    elsif self[:uid] == 6335
      self[:band] = '7'
    elsif self[:seitenzeile] == '331,6 und 332,1'
      # 6420
      self[:seitenzeile] = '331, 6 - 332, 1'
    elsif self[:seitenzeile] == '331,9 und 332,5'
      # 6421
      self[:seitenzeile] = '331, 9 - 332, 5'
    elsif self[:seitenzeile] == '114,4 114,7                                                114,4'
      # 7603
      self[:seitenzeile] = '114, 4-7'
    elsif self[:seitenzeile] == '47,5 47,5- 47,5'
      # 7616
      self[:seitenzeile] = '47, 5'
    elsif self[:seitenzeile] == '24;4'
      # 7693
      self[:seitenzeile] = '24, 4'
    elsif self[:seitenzeile] == '75,13 75,13 75,13'
      # 7875
      self[:seitenzeile] = '75, 13'
    elsif self[:seitenzeile] == '54;3'
      # 8222
      self[:seitenzeile] = '54, 3'
    elsif self[:seitenzeile] == '137, 008-138'
      # 8337
      self[:seitenzeile] = '137, 008 - 138, 10'
    elsif self[:seitenzeile] == '201; 008'
      # 8853
      self[:seitenzeile] = '201, 008'
    elsif self[:seitenzeile] == '067; 004'
      # 8918
      self[:seitenzeile] = '067, 004'
    elsif self[:seitenzeile] == '018; 009'
      # 8939
      self[:seitenzeile] = '018, 009'
    elsif self[:uid] == 9165
      self[:band] = '5'
    end

    myGott = {
        'uid' => self[:uid],
        #'id' => self[:uid],
        'transliteration' => self[:transliteration],
        'ort' => self[:ort],
        'eponym' => self[:eponym],
        'beziehung' => self[:beziehung],
        'funktion' => self[:funktion],
        'anmerkung' => self[:anmerkung]
    }
    gott += [myGott]

    # gelegentlich ist der Inhalt doppelt vorhanden
    szsz = self[:seitenzeile].gsub(' ', '')
    halbeLaenge = Integer(round(szsz.length / 2))
    halberString = szsz[halbeLaenge..-1]
    if (halberString + halberString) == szsz
      self[:seitenzeile] = halberString
    end

    self[:seitenzeile] = self[:seitenzeile].gsub('.09999999999999', ', 1')
    self[:seitenzeile] = self[:seitenzeile].gsub('.300000000000001', ', 3')
    self[:seitenzeile] = self[:seitenzeile].gsub('.30000000000001', ', 3')
    self[:seitenzeile] = self[:seitenzeile].gsub('.40000000000001', ', 4')
    self[:seitenzeile] = self[:seitenzeile].gsub('.59999999999999', ', 6')
    self[:seitenzeile] = self[:seitenzeile].gsub('.699999999999999', ', 7')
    self[:seitenzeile] = self[:seitenzeile].gsub('.69999999999999', ', 7')
    self[:seitenzeile] = self[:seitenzeile].gsub('.90000000000001', ', 9')
    self[:seitenzeile] = self[:seitenzeile].gsub('.109999999999999', ', 11')
    self[:seitenzeile] = self[:seitenzeile].gsub('.119999999999999', ', 12')
    self[:seitenzeile] = self[:seitenzeile].gsub('.140000000000001', ', 14')
    self[:seitenzeile] = self[:seitenzeile].gsub('.14000000000001', ', 14')
    self[:seitenzeile] = self[:seitenzeile].gsub('.15000000000001', ', 15')
    self[:seitenzeile] = self[:seitenzeile].gsub('.18000000000001', ', 18')

    match = self[:seitenzeile].match(/([0-9]+)\.([0-9]+)/)
    # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
    self[:seitenzeile] = self[:seitenzeile].gsub(/([0-9]+)\.([0-9]+)/, "#{match[1]}, #{match[2]}")

    # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
    self[:seitenzeile] = self[:seitenzeile].gsub(/und/, ';')

    if originalSEITEZEILE != self[:seitenzeile]
      logger.info "\t[INFO]  [GL] uid: #{self[:uid]} Änderung SEITEZEILE, original: #{originalSEITEZEILE} new: #{self[:seitezeile]}"
    end

    szs = self[:seitenzeile].match(/(^\s*;\s*)(.*)(\s*;\s*$)/)[2].split(';')
    if szs.length == 1 and szs[0].length > 1
      sz = szs[0]
      stopUnsicher = false
      sz = sz.match(/(^\s*,\s*)(.*)(\s*,\s*$)/)[2]
      komponenten = sz.split(',')
      if komponenten.length == 1
        # nur eine Komponente: nur eine Seitenzahl vorhanden, mit Zeile 0 ergänzen
        match = sz.match(/([0-9]*)(.*)/)
        # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
        sz = sz.gsub('([0-9]*)(.*)', "#{match[1]},0#{match[2]}")
        komponenten = sz.split(',')
      end

      if komponenten.length > 2
        sz = sz.gsub(' ', '')
        sz = sz.gsub('/', '-')
        sy = sz.split('-')
        if sy.length == 2
          start = szSplit(sy[0])
          stop = szSplit(sy[1])
          startSeite = start[0]
          startZeile = start[1]
          stopSeite = stop[0]
          stopZeile = stop[1]
        else
          logger.error "\t[ERROR]  [GL] uid: #{self[:uid]} SEITEZEILE, falsche Komponentenzahl: #{sz}"
        end

      else
        startSeite = Integer(komponenten[0])
        stopSeite = startSeite
        zeilen = komponenten[1].strip()
        if zeilen.match(/f/)

          stopUnsicher = true
          # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
          zeilen = zeilen.gsub(r '\s*f+\.*', '')
        end

        # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
        zeilen = zeilen.gsub(r '[ /-]+', '-')
        zs = zeilen.split('-')

        startZeile = int(zs[0])
        if zs.length > 1

          stopZeile = Integer(zs[1])
        else
          stopZeile = startZeile
        end
      end
      band = Integer(self[:band])
      if startSeite > 0 and band > 0

        myStelle = {
            # todo prüfen uid = stellenlönge ?
            'uid' => stelle.length,
            'band_uid' => band,
            'seite_start' => startSeite,
            'seite_stop' => stopSeite,
            'zeile_start' => startZeile,
            'zeile_stop' => stopZeile,
            'stop_unsicher' => stopUnsicher,
            'zerstoerung' => false,
            'anmerkung' => stelleAnmerkung
        }
        stelle += [myStelle]

        if myStelle['zeile_start'] > 30
          logger.error "\t[ERROR]  [GL] uid: #{self[:uid]} zeile_start > 30: #{sz}"
        end

        if myStelle['zeile_stop'] > 30
          logger.error "\t[ERROR]  [GL] uid: #{self[:uid]} zeile_stop > 30: #{sz}"
        end


        myGott['stelle_uid'] = myStelle['uid']
      else
        logger.error "\t[ERROR]  [GL] uid: #{self[:uid]} startSeite oder Band nicht ermittelbar: Datensatz verwerfen: #{sz}"
      end

    else
      logger.error "\t[ERROR]  [GL] uid: #{self[:uid]} nicht genau eine Stelle in SEITEZEILE: Datensatz verwerfen: #{self[:seitenzeile]}"
    end


    wort = []

    # wird unter der Tabelle WORT_HAS_STELLE (WORT_STELLE_MM) hinzugefügt
    wort_has_stelle = []
    # Wörterbuch Berlin mit Datensatz für 'nicht belegt'

    # wird unter der Tabelle BERLIN (WB_BERLIN) hinzugefügt
    berlin = [{
                  'uid' => 0,
                  'band' => 0,
                  'seite_start' => 0,
                  'seite_stop' => 0,
                  'zeile_start' => 0,
                  'zeile_stop' => 0,
                  'notiz' => nil
              }]

  end
end
