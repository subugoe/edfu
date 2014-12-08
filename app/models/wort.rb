# encoding: utf-8 

require 'edfu_model_helper'
require 'edfu_numerics_conversion_helper'
require 'rsolr'

class Wort < ActiveRecord::Base
  include EdfuNumericsConversionHelper
  extend EdfuModelHelper

  belongs_to :wb_berlin
  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  after_commit :add_to_solr
  before_validation :check_data


  private


  def check_data

    check_belegstellen_re1

  end

  def add_to_solr

    # todo extract
    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
    solr.add (
                 {
                     :sql_uid => self[:uid],

                     :transliteration => self[:transliteration],
                     :transliteration_nosuffix => self[:transliteration_nosuffix], # ---
                     :uebersetzung => self[:uebersetzung], # ---
                     :hieroglyph => self[:hieroglyph], # ---
                     :weiteres => self[:weiteres], # ---
                     :anmerkung => self[:anmerkung], # --- aus self, kein Array

                     :stelle_id => self.stellen.collect { |stelle| "stelle-#{stelle.id}" }, # ---
                     :band => self.stellen.collect { |stelle| stelle.band }, #
                     :bandseite => self.stellen.collect { |stelle| stelle.bandseite }, # ---
                     :bandseitezeile => self.stellen.collect { |stelle| stelle.bandseitezeile }, # ---
                     :seite_start => self.stellen.collect { |stelle| stelle.seite_start }, # ---
                     :seite_stop => self.stellen.collect { |stelle| stelle.seite_stop }, # ---
                     :zeile_start => self.stellen.collect { |stelle| stelle.zeile_start }, # ---
                     :zeile_stop => self.stellen.collect { |stelle| stelle.zeile_stop }, # ---
                     :zerstoerung => self.stellen.collect { |stelle| stelle.zerstoerung }, # ---
                     :freigegeben => self.stellen.collect { |stelle| stelle.freigegeben }, # ---
                     :stelle_unsicher => self.stellen.collect { |stelle| stelle.stelle_unsicher }, #

                     #:sort => "Ddt--#{self.wb_berlin.sort}", # ---  todo
                     :berlin_display => self.wb_berlin.berlin_display, # ---
                     :berlin_band => self.wb_berlin.band.to_i, # ---
                     :berlin_seite_start => self.wb_berlin.seite_start.to_i, # ---
                     :berlin_seite_stop => self.wb_berlin.seite_stop.to_i, # ---
                     :berlin_zeile_start => self.wb_berlin.zeile_start.to_i, # ---
                     :berlin_zeile_stop => self.wb_berlin.zeile_stop.to_i, # ---
                     :stelle_berlin_id => self.wb_berlin.id,

                     :typ => 'wort',
                     :id => "wort-#{self[:uid]}"
                 }
             )
    solr.commit
  end


  def check_belegstellen_re1

    # todo extract to module
    # Einträge für die 8 Chassinat Bände.
    bandDict = {
        1 => {'uid' => 1, 'nummer' => 1, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou I, 1892.',
              'tempel_uid' => 0},
        2 => {'uid' => 2, 'nummer' => 2, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou II, 1897.',
              'tempel_uid' => 0},
        3 => {'uid' => 3, 'nummer' => 3, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou III, 1928.',
              'tempel_uid' => 0},
        4 => {'uid' => 4, 'nummer' => 4, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou IV, 1929.',
              'tempel_uid' => 0},
        5 => {'uid' => 5, 'nummer' => 5, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou V, 1930.',
              'tempel_uid' => 0},
        6 => {'uid' => 6, 'nummer' => 6, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou VI, 1931.',
              'tempel_uid' => 0},
        7 => {'uid' => 7, 'nummer' => 7, 'freigegeben' => true, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou VII, 1932.',
              'tempel_uid' => 0},
        8 => {'uid' => 8, 'nummer' => 8, 'freigegeben' => true, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou VIII, 1933.',
              'tempel_uid' => 0}
    }

    wort = []

    # wird unter der Tabelle WORT_HAS_STELLE (WORT_STELLE_MM) hinzugefügt
    wort_has_stelle = []
    # Wörterbuch Berlin mit Datensatz für 'nicht belegt'

    # wird unter der Tabelle BERLIN (WB_BERLIN) hinzugefügt
    berlin = [
        {
            'uid' => 0,
            'band' => 0,
            'seite_start' => 0,
            'seite_stop' => 0,
            'zeile_start' => 0,
            'zeile_stop' => 0,
            'notiz' => nil
        }
    ]

    # Tabelle WL


    re20 = Regexp.new(/^\s*([VI]*)\s*,?\s*(<?)([0-9]*)\s*,\s*([0-9\/ -]*)(>?\*?)\s*(.*)$/)

    #--- edfu


    edfuAnmerkung = ''

    bEdfu = self[:belegstellenEdfu]

    if bEdfu.strip().end_with? (';')
      i = bEdfu.rindex(';')
      bEdfu = bEdfu[0..i-1]
    end

    # 2132, 2276, 2325
    bEdfu = bEdfu.gsub(/E VII/, 'VII')

    # 3189, 3239
    bEdfu = bEdfu.gsub(' f.', '')

    # 3514
    bEdfu = bEdfu.gsub('; ;', ';')


    if bEdfu.index('zum Beispiel') == 0
      # 1266, 1296, 2781, 2811
      bEdfu = bEdfu.gsub(/zum Beispiel/, '')
      edfuAnmerkung = '(Beispiele) '

    elsif bEdfu == 'VIII, 026, 4 f.; 033 16'
      # 3189
      bEdfu = 'VIII, 026, 4; 033, 16'

    elsif bEdfu == 'VII, 029, 05; 212; 13'
      # 27
      bEdfu = 'VII, 029, 05; 212, 13'
    elsif bEdfu == 'VII, 057, 04; 081, 04; 123, 11; 139, 08; 146, 17; 190, 11210, 14; 214, 16'
      # 824
      bEdfu = 'VII, 057, 04; 081, 04; 123, 11; 139, 08; 146, 17; 190, 11; 210, 14; 214, 16'
    elsif bEdfu == 'VII, 027, 08; 040, 11; 076, 11; 088, 04; 106, 01; 192; 02; 247, 02; 297, 01; 300, 16;  313, 02; 324, 16; 325, 01'
      # 825
      bEdfu = 'VII, 027, 08; 040, 11; 076, 11; 088, 04; 106, 01; 192, 02; 247, 02; 297, 01; 300, 16;  313, 02; 324, 16; 325, 01'
    elsif bEdfu == 'VII, 076, 06; 101, 04; 105, 14; 180, 14; 182, 05; 183, 03; 214, 08; 264, 07; 266, 02; 288, 03; 293; 08'
      # 1370
      bEdfu = 'VII, 076, 06; 101, 04; 105, 14; 180, 14; 182, 05; 183, 03; 214, 08; 264, 07; 266, 02; 288, 03; 293, 08'
    elsif bEdfu == 'VIII, 0,31, 07; 060, 07'
      # 2278
      bEdfu = 'VIII, 031, 07; 060, 07'
    elsif bEdfu == 'VIII, 033, 01; 068, 02; 098, 02; 103; 18; 162, 05; VII, 002, 07; 028, 08; 072, 17; 075, 07; 094, 02; 163, 14; 165, 14; 230, 10'
      # 2900
      bEdfu = 'VIII, 033, 01; 068, 02; 098, 02; 103, 18; 162, 05; VII, 002, 07; 028, 08; 072, 17; 075, 07; 094, 02; 163, 14; 165, 14; 230, 10'
    elsif bEdfu == 'VIII, 026, 4 f.; 033 16'
      # 3189
      bEdfu = 'VIII, 026, 04; 033 16'

    elsif bEdfu == 'VII, 273, 05 f.'
      # 3239
      bEdfu = 'VII, 273, 05'


    elsif bEdfu == 'VIII, 063 12'
      # 3853
      bEdfu = 'VIII, 063, 12'

    elsif bEdfu.index('<VIII, ') == 0
      # 732, 797, 804, 816, 2247, 2312, 2319, 2331
      bEdfu = 'VIII, <' + bEdfu[7..-1]
    elsif bEdfu.index('VII; ') == 0
      # 794
      bEdfu = 'VII, 128, 02; 172, 06; 285, 09'
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


    #bEdfu = bEdfu.strip('EPON; ')
    if match = bEdfu.match(/(^EPON; )(.*)(EPON; $)/)
      bEdfu = match[2]
    end

    # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
    bEdfu = bEdfu.gsub(/ \/ V/, '; V')


    if bEdfu != self[:belegstellenEdfu]
      edfuAnmerkung += 'ursprünglich: ' + self[:belegstellenEdfu]
      logger.info "\t[INFO]  [GL] uid: #{self[:uid]} Änderung BelegstellenEdfu, original: #{self[:belegstellenEdfu]} new: #{bEdfu}"
    end


    #-- wb_berlin


    wb = self[:belegstellenWb]
    wbID = nil
    wbAnmerkung = nil
    notiz = nil

    if wb == 'nicht im Wb belegt'
      wbID = 0
    elsif wb.length > 0
      if wb == 'nach II, 123, 12 - 124*'
        wb = 'nach II, 123, 12 - 124, 1'
        wbAnmerkung = '*'

      elsif wb == 'I, 171, 03 - 12; 18 - 21'
        # 356
        wb = 'I, 171, 03 - 12'
      elsif wb == 'II, 429 - 432, 05'
        # 1358-1361
        wb = 'II, 429, 01 - 432, 05'
      elsif wb == 'II, 498 - 500, 24'
        # 1418-1420
        wb = 'II, 498, 01 - 500, 24'

      elsif wb == 'I, 435. 16 - 18'
        # 1424
        wb = 'I, 435, 16 - 18'

      elsif wb == 'III, 026 - 027, 19'
        # 1441
        wb = 'III, 026,01 - 027, 19'

      end


      if wb != self[:belegstellenWb]
        wbAnmerkung = 'ursprünglich: ' + self[:belegstellenWb]
        logger.info "\t[INFO]  [GL] uid: #{self[:uid]} Änderung BelegstellenWb, original: #{self[:wbBelegstellen]} new: #{wb}"
      end


      # vornach =  1 'nach '
      # vornach = -1 'vor '
      vornach = 0
      if wb.index('nach ') == 0
        vornach = 1
        wb = wb.gsub(/nach /, '')
      elsif wb.index('vor ') == 0
        vornach = -1
        wb = wb.gsub(/vor /, '')
      end

      wbBand_roemisch = wb[0 .. wb.index(',')-1]

      wb = wb[wb.index(',') + 1 .. -1].strip()
    end


    # band = roemisch[roemischBand]
    wbBand = roemisch_nach_dezimal(wbBand_roemisch)

    wb = wb.gsub(' -', '-').gsub('- ', '-')

    if wb.index('-') != nil
      # Range
      wbTeile = wb.split('-')
      if wbTeile.length == 2
        wbSeiteZeile = wbTeile[0].split(',')
        wbSeiteStart = (wbSeiteZeile[0].strip()).to_i
        wbSeiteStop = wbSeiteStart


        #logger.debug "\t[DEBUG]  [WL] uid: #{self[:uid]} wb: #{wb}, seitezeile: #{wbSeiteZeile}, start: #{wbSeiteStart}, stop: #{wbSeiteStop}"

        begin
          if wbSeiteZeile[1] != nil and wbSeiteZeile[1].strip() != ''
            wbZeileStart = (wbSeiteZeile[1].strip()).to_i # if wbSeiteZeile[1] != nil
          else
            wbZeileStart = 1
            logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} Datensatz mit BelegstellenWb #{wb} überprüfen -> ZeileStart auf 1 gesetzt"
          end
        rescue ArgumentError
          logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} Datensatz mit BelegstellenWb #{wbSeiteZeile[0]} überprüfen"
        end

        if wbTeile[1].index(',') != nil
          # Komma im zweiten Teil: unterschiedliche Seiten
          wbSeiteZeile2 = wbTeile[1].split(',')
          wbSeiteStop = (wbSeiteZeile2[0].strip()).to_i
          wbZeileStop = (wbSeiteZeile2[1].strip()).to_i
        else
          # Range innerhalb einer Seite
          wbZeileStop = (wbTeile[1].strip()).to_i
        end

        # todo geändert
        # von: stop = [seiteStart, zeileStop]
        # nach: stop = [seiteStop, zeileStop]
        wbStart = [wbSeiteStart, wbZeileStart]
        wbStop = [wbSeiteStop, wbZeileStop]

      else
        logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} BelegstellenWb Formatfehler #{wb}"
      end

    else
      # Nur eine Stelle
      begin
        wbStart = szSplit(wb)
      rescue ArgumentError
        logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} Stelle  #{wb} konnte nicht gesplittet werden"
      end
      wbStop = wbStart
    end


    # bereitsVorhanden = false
    #
    # # hat 1:1 relation;  todo wird das noch gebraucht?
    # if (self.wb_berlin != nil and
    #     self.wb_berlin.seite_start == wbSeiteStart and
    #     self.wb_berlin.band == wbBand and
    #     self.wb_berlin.seite_stop == wbSeiteStop and
    #     self.wb_berlin.zeile_start == wbZeileStart and
    #     self.wb_berlin.zeile_stop == wbZeileStop)
    #
    #   self.wb_berlin.notiz = wbAnmerkung if self.wb_berlin.notiz != wbAnmerkung
    #
    #   bereitsVorhanden = true
    # end
    #
    #
    # unless bereitsVorhanden


    dbWB = WbBerlin.create(
        :band => wbBand || 'unbekannt',
        :seite_start => wbStart[0] || '',
        :seite_stop => wbStop[0] || '',
        :zeile_start => wbStart[1] || '',
        :zeile_stop => wbStop[1] || '',
        :notiz => wbAnmerkung || ''
    )
    self.wb_berlin = dbWB # unless self.wb_berlin == dbWB

    #end


    #--- edfu


    if edfuAnmerkung != '' or edfuAnmerkung.length != 0
      if self[:anmerkung] == nil or self[:anmerkung] == ''
        self[:anmerkung] = "#{edfuAnmerkung.strip()}"
      else
        self[:anmerkung] = "#{edfuAnmerkung.strip()}; #{self[:anmerkung].strip() || ''}"
      end
    else
      self[:anmerkung] = "#{self[:anmerkung].strip() || ''}"
    end


    edfuBandNr = 0
    edfuSeiteStart = 0
    zerstoerung = false
    bandRoemisch = ''
    bandDezimal = 0

    if bEdfu.length > 0
      belegstellen = bEdfu.split(';')

      belegstellen.each { |b|
        b = b.strip()

        klammer = false
        stern = false

        if b.index('%') != nil
          zerstoerung = true
          b = b.gsub('%', '').gsub('&', '')

        end

        if b.index(',') == nil
          if edfuSeiteStart != 0
            b = edfuSeiteStart.to_s + ', ' + b
            #					print "\t".join(["WL", str(self[:uid]), "INFO", u"Seitenzahl hinzugefügt", b])
          else
            logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} keine Seitenzahl #{b} :: #{bEdfu}"
          end

        end

        m20 = re20.match(b)

        if m20
          if (m20[1]).length > 0

            bandRoemisch = m20[1].strip()
            bandDezimal = roemisch_nach_dezimal bandRoemisch
            edfuBandNr = bandDezimal # roemisch[m20[1].strip()]
          elsif edfuBandNr == 0
            logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} FEHLER", "fehlende Bandangabe #{b}"
          end

          edfuSeiteStart = m20[3].to_i
          edfuSeiteStop = edfuSeiteStart
          edfuAnmerkung = ''

          if m20[4].index(' - ') != nil
            edfuZeileStart = (m20[4].split(' - ')[0]).to_i
            edfuZeileStop = (m20[4].split(' - ')[1]).to_i
          else
            zeilenString = m20[4]
            zeilenString = zeilenString.gsub('/', '-').gsub(' ', '')
            zeilen = zeilenString.split('-')

            if zeilen.length == 1
              edfuZeileStart = zeilen[0].to_i
              edfuZeileStop = edfuZeileStart

            elsif zeilen.length == 2
              edfuZeileStart = (zeilen[0]).to_i
              edfuZeileStop = (zeilen[1]).to_i
            else
              logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} zu viele Komponenten in Zeilenangabe: #{b}"
            end

            edfuAnmerkung = m20[6].strip()
          end

          if m20[5] == '>'
            klammer = true
          elsif m20[5] == '>*'
            stern = true
          elsif (m20[5]).length > 2
            logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} m20[5] zu lang #{b}"
          end

          # todo nicht korrekt
          stelle = Stelle.create(
              :tempel => 'Edfu',
              :band => edfuBandNr,
              :bandseite => "#{bandRoemisch}, #{'%03i' % (edfuSeiteStart)}",
              :bandseitezeile => "#{bandRoemisch}, #{'%03i' % (edfuSeiteStart)}, #{'%02i' % (edfuZeileStart)}",
              :seite_start => edfuSeiteStart,
              :seite_stop => edfuSeiteStop,
              :zeile_start => edfuZeileStart,
              :zeile_stop => edfuZeileStop,
              :stelle_anmerkung => edfuAnmerkung,
              :stelle_unsicher => false,
              # :start => "#{edfuBandNr}#{'%03i' % (edfuSeiteStart)}#{'%03i' % (edfuZeileStart)}",
              # :stop => "#{edfuBandNr}#{'%03i' % (edfuSeiteStop)}#{'%03i' % (edfuZeileStop)}",
              :zerstoerung => false,
              :freigegeben => bandDict[(edfuBandNr).to_i]['freigegeben']
          )
          self.stellen << stelle unless self.stellen.include? stelle


          if edfuZeileStart == nil
            logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} zeile_start == nil; #{b}"
          elsif edfuZeileStart > 30
            logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} zeile_start > 30; #{b}"
          end

          if edfuZeileStart == nil
            logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} zeile_stop  == nil; #{b}"
          elsif edfuZeileStop > 30
            logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} zeile_stop > 30;  #{b}"
          end


        else
          logger.error "\t[ERROR]  [WL] uid: #{self[:uid]} keine erkennbare Seitenzahl #{b}"
        end
      }
    end
  end

# todo in module auslagern
  def szSplit(s)
    parts = s.gsub(' ', '').split(',')

    begin
      parts = [(parts[0]).to_i, (parts[1]).to_i]
    rescue ArgumentError
      logger.error "\t[ERROR]  [FL] Fehler bei der Auftrennung von: #{s} aufgelöst nach: #{parts}"
    end

    return parts
  end

end
