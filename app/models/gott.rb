# encoding: utf-8 

require 'lib/edfu_model_helper'
require 'lib/edfu_numerics_conversion_helper'
require 'rsolr'


class Gott < ActiveRecord::Base
  include EdfuNumericsConversionHelper
  extend EdfuModelHelper

  # todo has_many or has_one?
  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  attr_accessor :stelle, :transliteration_nosuffix

  # after_update :log_updated
  # after_create :log_created
  after_commit :add_to_solr
  before_validation :check_data


  # searchable do
  #
  #   integer :uid, stored: true
  #   text :transliteration, stored: true # todo transliteration_highlight hinzufügen
  #   text :transliteration_nosuffix, stored: true
  #   text :ort, stored: true
  #   text :eponym, stored: true
  #   text :beziehung, stored: true
  #   text :funktion, stored: true
  #   integer :band, stored: true
  #   text :seitezeile, stored: true # todo wirklich in den index?
  #   text :anmerkung, stored: true
  #   # todo stelle_id und attr. aus Stelle hinzufügen, und bandseitezeile_highlight hinzufügen
  #   # todo id hinzufügen, typ hinzufügen,
  #
  # end


  private


  def check_data

    check_seitezeile_re_1

  end

  def add_to_solr

    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'

    solr.add (
                 {
                     :sql_uid => self[:uid], # ? ---
                     :transliteration => self[:transliteration], # ---
                     #:transliteration_highlight => self[:transliteration], # ---
                     :transliteration_nosuffix => self[:transliteration], # ? ---
                     :ort => self[:ort], # ---
                     :eponym => self[:eponym], # ---
                     :beziehung => self[:beziehung], # ---
                     :funktion => self[:funktion], # ---
                     :band => self[:band].to_i, # ---
                    # :seitezeile => self[:seitezeile], # ? new
                     :anmerkung => self[:anmerkung], # ---
                   #  :sort => "Act--#{self.stelle.start}", # ---
                     :freigegeben => self[:freigegeben], # ---
                     :zerstörung => self[:zerstoerung], # ---

                     # :stelle_unsicher => self.stelle.unsicher, # ? ---
                     # :seite_start => self.stelle.seite_start, # ? ---
                     # :seite_stop => self.stelle.seite_stop, # ? ---
                     # :zeile_start => self.stelle.zeile_start, # ? ---
                     # :zeile_stop => self.stelle.zeile_stop, # ? ---
                     # :bandseite => self.stelle.bandseite, # ? ---
                     # :bandseitezeile => self.stelle.bandseitezeile, # ? ---
                     # #:bandseitezeile_highlight => self.stelle.bandseitezeile, # ? ---
                     # :stelle_id => self.stelle.id, # ---
                     # :start => self.stelle.start, # ? new
                     # :stop => self.stelle.stop, # ? new

                     :typ => 'gott', # ---
                     :id => "gott-#{self[:uid]}" # ---
                 }
             )


    #   integer :band, stored: true
    #   text :seitezeile, stored: true # todo wirklich in den index?
    #   text :anmerkung, stored: true
    #   # todo stelle_id und attr. aus Stelle hinzufügen, und bandseitezeile_highlight hinzufügen
    #   # todo id hinzufügen, typ hinzufügen,

    solr.commit

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


    gott = []
    gott_has_stelle = []

    # Tabelle GL

    re3 = Regexp.new(/^\s*([VI]*)\s*,*\s*([0-9]*)\s*,\s*([0-9\/ -]*)\s*(.*)$/)


    originalSEITEZEILE = self[:seitezeile]
    stelleAnmerkung = ''

    if self[:seitezeile] == '066, 011ff,;'
      # 84
      self[:seitezeile] = '066, 011ff'
    elsif self[:seitezeile] == '264-269;'
      # 1551
      self[:seitezeile] = '264, 0 - 269, 30;'
    elsif self[:seitezeile] == '2,7?'
      # 1178
      self[:seitezeile] = '2, 7'
      stelleAnmerkung = '2,7?'
    elsif self[:seitezeile] == '052, 006 und 008;'
      # 2376
      self[:seitezeile] = '052, 6-8'
    elsif self[:seitezeile] == '215, 11 (2x)-216, 1 (1'
      # 2463
      self[:seitezeile] = '215, 11 - 216, 1'
    elsif self[:seitezeile] == '159'
      # 3266
      self[:seitezeile] = '159, 0'
    elsif self[:seitezeile] == '149, 3:'
      # 3654
      self[:seitezeile] = '149, 3'
    elsif self[:seitezeile] == '90, 3 (25);'
      # 4093
      self[:seitezeile] = '90, 3;'
      stelleAnmerkung = '(25)'
    elsif self[:seitezeile] == '39, 11/f.'
      # 5487
      self[:seitezeile] = '39, 11f.'
    elsif self[:seitezeile] == '90,3 (36)'
      # 5758
      self[:seitezeile] = '90,3'
      stelleAnmerkung = '(36)'
    elsif self[:seitezeile] == '33,14 33,14'
      # 5791
      self[:seitezeile] = '33, 14'
    elsif self[:uid] == 6335
      self[:band] = 'VII' # 7'
    elsif self[:seitezeile] == '331,6 und 332,1'
      # 6420
      self[:seitezeile] = '331, 6 - 332, 1'
    elsif self[:seitezeile] == '331,9 und 332,5'
      # 6421
      self[:seitezeile] = '331, 9 - 332, 5'
    elsif self[:seitezeile] == '114,4 114,7                                                114,4'
      # 7603
      self[:seitezeile] = '114, 4-7'
    elsif self[:seitezeile] == '47,5 47,5- 47,5'
      # 7616
      self[:seitezeile] = '47, 5'
    elsif self[:seitezeile] == '24;4'
      # 7693
      self[:seitezeile] = '24, 4'
    elsif self[:seitezeile] == '75,13 75,13 75,13'
      # 7875
      self[:seitezeile] = '75, 13'
    elsif self[:seitezeile] == '54;3'
      # 8222
      self[:seitezeile] = '54, 3'
    elsif self[:seitezeile] == '137, 008-138'
      # 8337
      self[:seitezeile] = '137, 008 - 138, 10'
    elsif self[:seitezeile] == '201; 008'
      # 8853
      self[:seitezeile] = '201, 008'
    elsif self[:seitezeile] == '067; 004'
      # 8918
      self[:seitezeile] = '067, 004'
    elsif self[:seitezeile] == '018; 009'
      # 8939
      self[:seitezeile] = '018, 009'
    elsif self[:uid] == 9165
      self[:band] = 'V' # '5'
    end

    # myGott = {
    #     'uid' => self[:uid],
    #     #'id' => self[:uid],
    #     'transliteration' => self[:transliteration],
    #     'ort' => self[:ort],
    #     'eponym' => self[:eponym],
    #     'beziehung' => self[:beziehung],
    #     'funktion' => self[:funktion],
    #     'anmerkung' => self[:anmerkung]
    # }
    # gott += [myGott]

    # gelegentlich ist der Inhalt doppelt vorhanden
    szsz = self[:seitezeile].gsub(' ', '')
    halbeLaenge = (szsz.length / 2).to_i
    halberString = szsz[halbeLaenge..-1]
    if (halberString + halberString) == szsz
      self[:seitezeile] = halberString
    end

    self[:seitezeile] = self[:seitezeile].gsub('.09999999999999', ', 1')
    self[:seitezeile] = self[:seitezeile].gsub('.300000000000001', ', 3')
    self[:seitezeile] = self[:seitezeile].gsub('.30000000000001', ', 3')
    self[:seitezeile] = self[:seitezeile].gsub('.40000000000001', ', 4')
    self[:seitezeile] = self[:seitezeile].gsub('.59999999999999', ', 6')
    self[:seitezeile] = self[:seitezeile].gsub('.699999999999999', ', 7')
    self[:seitezeile] = self[:seitezeile].gsub('.69999999999999', ', 7')
    self[:seitezeile] = self[:seitezeile].gsub('.90000000000001', ', 9')
    self[:seitezeile] = self[:seitezeile].gsub('.109999999999999', ', 11')
    self[:seitezeile] = self[:seitezeile].gsub('.119999999999999', ', 12')
    self[:seitezeile] = self[:seitezeile].gsub('.140000000000001', ', 14')
    self[:seitezeile] = self[:seitezeile].gsub('.14000000000001', ', 14')
    self[:seitezeile] = self[:seitezeile].gsub('.15000000000001', ', 15')
    self[:seitezeile] = self[:seitezeile].gsub('.18000000000001', ', 18')


    if match = self[:seitezeile].match(/([0-9]+)\.([0-9]+)/)
      self[:seitezeile] = self[:seitezeile].gsub(/([0-9]+)\.([0-9]+)/, "#{match[1]}, #{match[2]}") # (..), (..)
    end

    self[:seitezeile] = self[:seitezeile].gsub(/und/, ';')

    if originalSEITEZEILE != self[:seitezeile]
      logger.info "\t[INFO]  [GL] uid: #{self[:uid]} Änderung SEITEZEILE, original: #{originalSEITEZEILE} new: #{self[:seitezeile]}"
    end

    # todo check this
    if match = self[:seitezeile].match(/(^\s*;*\s*)([0-9 ,]*)(\s*;*\s*$)/) #(/(^\s*;\s*)(.*)(\s*;\s*$)/)
      szs = match[2].split(';')
      if szs.length == 1 and szs[0].length > 1
        sz = szs[0]
        stopUnsicher = false
        if match = sz.match(/(^\s*,*\s*)([0-9 ,]*)(\s*,*\s*$)/)
          sz = match[2]
          komponenten = sz.split(',')
          if komponenten.length == 1
            # nur eine Komponente: nur eine Seitenzahl vorhanden, mit Zeile 0 ergänzen
            match = sz.match(/([0-9]*)(.*)/)

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
            startSeite = (komponenten[0]).to_i
            stopSeite = startSeite
            zeilen = komponenten[1].strip()
            if zeilen.match(/f/)

              stopUnsicher = true
              # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
              zeilen = zeilen.gsub(/\s*f+\.*/, '')
            end

            # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
            zeilen = zeilen.gsub(/[ \/-]+/, '-')
            zs = zeilen.split('-')

            startZeile = (zs[0]).to_i
            if zs.length > 1

              stopZeile = (zs[1]).to_i
            else
              stopZeile = startZeile
            end
          end

          band = roemisch_nach_dezimal(self[:band])
          #band = (self[:band]).to_i

          if startSeite > 0 and band > 0

            # myStelle = {
            #     # todo prüfen uid = stellenlönge ?
            #     'uid' => stelle.length,
            #     'band_uid' => band,
            #     'seite_start' => startSeite,
            #     'seite_stop' => stopSeite,
            #     'zeile_start' => startZeile,
            #     'zeile_stop' => stopZeile,
            #     'stop_unsicher' => stopUnsicher,
            #     'zerstoerung' => false,
            #     'anmerkung' => stelleAnmerkung
            # }
            # stelle += [myStelle]


            # todo extract to module
            stelle = Stelle.create(
                :tempel => 'Edfu',
                :band => band,
                :bandseite => "#{self[:band]}, #{'%03i' % (startSeite)}",
                :bandseitezeile => "#{self[:band]}, #{'%03i' % (startSeite)}, #{'%02i' % (startZeile)}",
                :seite_start => startSeite,
                :seite_stop => stopSeite,
                :zeile_start => startZeile,
                :zeile_stop => stopZeile,
                :stelle_anmerkung => stelleAnmerkung,
                :stelle_unsicher => stopUnsicher,
                :start => "#{band}#{'%03i' % (startSeite)}#{'%03i' % (startZeile)}",
                :stop => "#{band}#{'%03i' % (stopSeite)}#{'%03i' % (stopZeile)}",
                :zerstoerung => false,
                :freigegeben => bandDict[(band).to_i]['freigegeben']
            )
            self.stellen << stelle unless self.stellen.include? stelle


            if startZeile > 30
              logger.error "\t[ERROR]  [GL] uid: #{self[:uid]} zeile_start > 30: #{sz}"
            end

            if stopZeile > 30
              logger.error "\t[ERROR]  [GL] uid: #{self[:uid]} zeile_stop > 30: #{sz}"
            end


            # myGott['stelle_uid'] = myStelle['uid']

          else
            logger.error "\t[ERROR]  [GL] uid: #{self[:uid]} startSeite oder Band nicht ermittelbar: Datensatz verwerfen: #{sz}"
          end

        else
          logger.error "\t[ERROR]  [GL] uid: #{self[:uid]} nicht genau eine Stelle in SEITEZEILE: Datensatz verwerfen: #{self[:seitezeile]}"
        end
      end
    end

  end
end
