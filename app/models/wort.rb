# encoding: utf-8 

require 'lib/edfu_model_helper'

class Wort < ActiveRecord::Base
  extend EdfuModelHelper

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



          roemischBand = wb[0..wb.index(',')]

          wb = wb[wb.index(',') + 1].strip()

      end
  end
end
