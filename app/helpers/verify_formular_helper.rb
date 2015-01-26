# encoding: utf-8

require 'edfu_numerics_conversion_helper'
require 'stellen_helper'

module VerifyFormularHelper
  include EdfuNumericsConversionHelper #, Celluloid

  def formular_literatur_relation_hash
    {
        1  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        2  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        3  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        4  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 2, 'detail' => '10 (38.), u. n. 40*'}],
        5  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        6  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 4, 'detail' => '309, n. 11'},
               {'literatur_beschreibung_key' => 5, 'detail' => '515, n. 135'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        7  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        8  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        9  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        10 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        11 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        12 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        13 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        14 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        15 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        16 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        17 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}]
    }
  end

  def literatur_beschreibung_hash
    return {
        1 => 'Bedier, in: GM 162, 1998',
        2 => 'Budde/Kurth, in: EB 4, 1994',
        3 => 'Labrique, Stylistique',
        4 => 'Aufrère, L’univers minéral I',
        5 => 'Aufrère, L’univers minéral II'
    }
  end


  private
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


# per callback aufgerufen
  def create_literaturen(uid, formular)

    literaturen = Array.new


    if arr = formular_literatur_relation_hash[uid.to_i]
      arr.each { |hash|

        beschreibung = literatur_beschreibung_hash[hash['literatur_beschreibung_key']]
        detail       = hash['detail']

        lit = Literatur.fetch(
            beschreibung,
            detail
        )

        if lit.class == Array
          lit = lit[0]
          literaturen << lit
        end

        #literaturen << lit # unless self.literaturen.include? lit
        formular.literaturen << lit unless formular.literaturen.include? lit
      }
    end

    return literaturen
  end


  def create_stellen(seitezeile, band, uid) # , formular)

    # # todo extract to module
    # # Einträge für die 8 Chassinat Bände.
    # bandDict    = {
    #     1 => {'uid'        => 1, 'nummer' => 1, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou I, 1892.',
    #           'tempel_uid' => 0},
    #     2 => {'uid'        => 2, 'nummer' => 2, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou II, 1897.',
    #           'tempel_uid' => 0},
    #     3 => {'uid'        => 3, 'nummer' => 3, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou III, 1928.',
    #           'tempel_uid' => 0},
    #     4 => {'uid'        => 4, 'nummer' => 4, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou IV, 1929.',
    #           'tempel_uid' => 0},
    #     5 => {'uid'        => 5, 'nummer' => 5, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou V, 1930.',
    #           'tempel_uid' => 0},
    #     6 => {'uid'        => 6, 'nummer' => 6, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou VI, 1931.',
    #           'tempel_uid' => 0},
    #     7 => {'uid'        => 7, 'nummer' => 7, 'freigegeben' => true, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou VII, 1932.',
    #           'tempel_uid' => 0},
    #     8 => {'uid'        => 8, 'nummer' => 8, 'freigegeben' => true, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou VIII, 1933.',
    #           'tempel_uid' => 0}
    # }

    #band = []
    #stelle = []

    anmerkung   = ''

    # Felder
    #@myFormular['texttyp'] = self[:texttyp]

    # Textposition

    # todo Konversion absichern Integer("1")

    myStelle    = {}
    # todo entfernen? Gehört zur Normalisierung
    band_uid    = band #bandDict[(self[:band]).to_i]['nummer']
    # freigegeben = bandDict[band.to_i]['freigegeben']
    freigegeben = StellenHelper.getFromBanddicet((band).to_i, 'freigegeben')

    ## Sonderfälle
    szOriginal  = seitezeile
    if uid == 3416
      seitezeile = "011, 09 - 012, 01"
    end
    if uid == 9583
      seitezeile = "078, 14 / Kol. 1"
    end
    if uid == 9584
      seitezeile = "078, 14 / Kol. 2"
    end

    kommentar = []

    if seitezeile.index('nach ') == 0
      kommentar  += ['nach']
      seitezeile = seitezeile.gsub('nach ', '')
    end

    if seitezeile.index(', Z') != nil
      kommentar  += [seitezeile[seitezeile.index(', Z') + 2..-1]]
      seitezeile = seitezeile[0..seitezeile.index(', Z')]
    end

    if seitezeile.index(' / Z') != nil
      kommentar  += [seitezeile[seitezeile.index(' / Z') + 3..-1]]
      seitezeile = seitezeile[0..seitezeile.index(' / Z')]
    end

    if seitezeile.index(', Kol') != nil
      kommentar += [seitezeile[seitezeile.index(', Kol') + 2..-1]]
      seitezeile= seitezeile[0..seitezeile.index(', Kol')]
    end

    if seitezeile.index(' / kol') != nil
      kommentar += [seitezeile[seitezeile.index(' / kol') + 3..-1]]
      seitezeile= seitezeile[0..seitezeile.index(' / kol')]
    end

    if seitezeile.index(' / ') != nil
      kommentar += [seitezeile[seitezeile.index(' / ') + 3..-1]]
      seitezeile= seitezeile[0..seitezeile.index(' / ')]
    end

    if szOriginal != seitezeile
      logger.info "\t[INFO]  [FL] uid: #{uid} Aenderung SEITEZEILE, Original: #{szOriginal} neu: #{seitezeile}"
    end
    if (kommentar.length) > 0
      logger.info "\t[INFO]  [FL] uid: #{uid} SEITEZEILE + Kommentar: #{kommentar}"
    end
    if (seitezeile.scan(/[^0-9, -]/)).length > 0
      logger.error "\t[ERROR]  [FL] uid: #{uid} Fehler mit SEITEZEILE,  #{seitezeile}"
    end

    if anmerkung != nil and anmerkung != ''
      anmerkung += "; #{kommentar}"
    else
      anmerkung = "#{kommentar}"
    end

    result = []

    seitezeile    = seitezeile
    band_roemisch = dezimal_nach_roemisch(band)


    if seitezeile.index(' - ') != nil # mit leerzeichen  bsp: 002, 06 - 003, 02
      szParts = seitezeile.split(' - ') # ["002, 06", "003, 02"]
      result << szSplit(szParts[0]) # ["002, 06"]
      result << szSplit(szParts[1]) # ["003, 02"]
    elsif seitezeile.index(',') != nil # ohne leerzeichen  bsp: 008, 08-09
      parts = seitezeile.split(',') # ["008", " 08-09"]
      seite = (parts[0]).to_i # 008
      if parts[1].index('-') != nil
        zeilen = parts[1].split('-') # ["08","09"]
        result = [[seite, (zeilen[0]).to_i], [seite, (zeilen[1]).to_i]] # [[008,08],[008,09]]
      else
        zeile  = (parts[1]).to_i
        result = [[seite, zeile], [seite, zeile]]
      end
    else
      result = [[0, 0], [0, 0]]
      logger.error "\t[ERROR]  [FL] uid: #{uid} Fehler mit SEITEZEILE,  #{seitezeile}"
    end

    # eine seite  (drei ziffern: 007 oder 012)
    if result[0][0] == result[1][0]
      # eine zeile (zwei ziffern: 04 oder 12)
      if result[0][1] == result[1][1]
        bandseitezeile = "#{band_roemisch}, #{'%03i' % (result[0][0])}, #{'%02i' % (result[0][1])}"
      else
        bandseitezeile = "#{band_roemisch}, #{'%03i' % (result[0][0])}, #{'%02i' % (result[0][1])}-#{'%02i' % (result[1][1])}"
      end
    else
      bandseitezeile = "#{band_roemisch}, #{'%03i' % (result[0][0])}, #{'%02i' % (result[0][1])} - #{'%03i' % (result[1][0])}, #{'%02i' % (result[1][1])}"
    end


    bandseite = "#{band_roemisch}, #{'%03i' % (result[0][0])}"

    if result[0][0] > result[1][0]
      logger.error "\t[ERROR]  [FL] uid: #{uid} Fehler , SEITEN absteigend,  #{seitezeile}"
    end

    if result[0][0] == result[1][0] and result[0][1] > result[1][1]
      logger.error "\t[ERROR]  [FL] uid: #{uid} Fehler, ZEILEN absteigend,  #{seitezeile}"
    end

    seite_start = result[0][0]
    zeile_start = result[0][1]
    seite_stop  = result[1][0]
    zeile_stop  = result[1][1]

    if zeile_start > 30
      logger.error "\t[ERROR]  [FL] uid: #{uid} Fehler, zeile_start > 30,  #{seitezeile}"
    end

    if zeile_stop > 30
      logger.error "\t[ERROR]  [FL] uid: #{uid} Fehler, zeile_stop > 30,  #{seitezeile}"
    end


    stop_unsicher = false
    zerstoerung   = false

    # # todo Teil der Normalisierung ?
    # uid = stelle.length
    # @myFormular['stelle_uid'] = stelle.length

    # stelle << [myStelle]
    # @formularDict[@myFormular['uid']] = @myFormular

    stelle        = Stelle.fetch(
        "formular",
        'Edfu',
        band_uid,
        bandseite,
        bandseitezeile,
        seite_start,
        seite_stop,
        zeile_start,
        zeile_stop,
        anmerkung,
        stop_unsicher,
        zerstoerung,
        freigegeben
    )

    #formular.stellen << stelle

    return stelle

  end


  def manipulate_photo_string_and_create(origPhoto, uid, formular)

    photos = Array.new

    photo = origPhoto

    case origPhoto
      # 263
      when 'D05_5503, D05_5504, D05_5509, D05_5510, D05_5511, D05_5512: D05_5513, D05_5514, ( 2982, 2983, 2984, 2985 )*'
        photo = 'D05_5503, D05_5504, D05_5509, D05_5510, D05_5511, D05_5512, D05_5513, D05_5514, ( 2982, 2983, 2984, 2985 )*'
      # 409
      when 'D05_6555, D06_6556, D05_6557, D05_6558, D05_6559, D05_6560, D05_6561, ( 1605, 1606 )*'
        photo = 'D05_6555, D05_6556, D05_6557, D05_6558, D05_6559, D05_6560, D05_6561, ( 1605, 1606 )*'
      # 1137-1138
      when 'D05_4151, D05_4152, D05_4153, D05_4160: D05_4161, D05_4162, D05_4163, D05_4164, D05_4165, D05_4166, D05_4167, D05_4168, D05_4169, ( 1615, 1616 )*'
        photo = 'D05_4151, D05_4152, D05_4153, D05_4160, D05_4161, D05_4162, D05_4163, D05_4164, D05_4165, D05_4166, D05_4167, D05_4168, D05_4169, ( 1615, 1616 )*'
      # 1155-1156
      when 'D05_3779, D05_3780, D05_3787, D05_3788, D05_3789, D05_3790, D05_3791, D05_3792, D05_3793, D05_3794, D05_3795, D05_3796, D05_4094, D05_:4095, D05_4102, D05_4103, D05_4104: D05_4105, D05_4106, D05_4107, D05_4108, D05_4109, ( 1616, 1617 )*'
        photo = 'D05_3779, D05_3780, D05_3787, D05_3788, D05_3789, D05_3790, D05_3791, D05_3792, D05_3793, D05_3794, D05_3795, D05_3796, D05_4094, D05_4095, D05_4102, D05_4103, D05_4104, D05_4105, D05_4106, D05_4107, D05_4108, D05_4109, ( 1616, 1617 )*'
      # 1157-1159
      when 'D05_3771, D05_3772, D05_3773, D05_3774, D05-3775, D05_3776, D05_3777, D05_3778, D05_3779, D05_3780, D05_3783, D05_3784, D05_3786, D05_4085, D05_4086, D05_4087, D05_4088, D05_4089, D05_4090, D05_4091, D05_4092, D05_4093, D05_4094, D05_4095, D05_4099, D05_4100, D05_4101, ( 1616, 1617 )*'
        photo = 'D05_3771, D05_3772, D05_3773, D05_3774, D05_3775, D05_3776, D05_3777, D05_3778, D05_3779, D05_3780, D05_3783, D05_3784, D05_3786, D05_4085, D05_4086, D05_4087, D05_4088, D05_4089, D05_4090, D05_4091, D05_4092, D05_4093, D05_4094, D05_4095, D05_4099, D05_4100, D05_4101, ( 1616, 1617 )*'
      # 1163-1165
      when 'D05_3764, D05_3765, D05_3766, D05_3767, D05_3768, D05_3769, D05_3770, D05_4068, D05_4069, D05_4070, D05_4071, D05_4072, D05_4073, D04_4074, D05_4075, D05_4076, D05_4077, D05_4078, D05_4079, D05_4080, D05_4081, D05_4082, D05_4083, D05_4084, ( 1617, 1618, 1619 )*'
        photo = 'D05_3764, D05_3765, D05_3766, D05_3767, D05_3768, D05_3769, D05_3770, D05_4068, D05_4069, D05_4070, D05_4071, D05_4072, D05_4073, D05_4074, D05_4075, D05_4076, D05_4077, D05_4078, D05_4079, D05_4080, D05_4081, D05_4082, D05_4083, D05_4084, ( 1617, 1618, 1619 )*'
      # 1167-1169
      when 'D05_3764, D05_3765, D05_3766, D05_3767, D05_3768, D05_3769, D05_3770, D05_4068, D05_4069, D05_4070, D05_4071, D05_4072, D05_4073, D04_4074, D05_4075, ( 1618, 1619, 1620 )*'
        photo = 'D05_3764, D05_3765, D05_3766, D05_3767, D05_3768, D05_3769, D05_3770, D05_4068, D05_4069, D05_4070, D05_4071, D05_4072, D05_4073, D05_4074, D05_4075, ( 1618, 1619, 1620 )*'
      # 1381-1382
      when 'D05_3678, D05_3822, D05_3823, D05_3824, D05_3825, D05_3826, D05_3827, D05_3828, D05_3829, D05_3830, D05_3831, D05_3832, D05_3833, D05_4297, D05_4298, D05_4299, D05_4300, D05_4301, D05_4302, D05_4560, D05_4561, D05-4562, D05_4563, D05_4564, D05_4565, ( 3471, 3474 )*'
        photo = 'D05_3678, D05_3822, D05_3823, D05_3824, D05_3825, D05_3826, D05_3827, D05_3828, D05_3829, D05_3830, D05_3831, D05_3832, D05_3833, D05_4297, D05_4298, D05_4299, D05_4300, D05_4301, D05_4302, D05_4560, D05_4561, D05_4562, D05_4563, D05_4564, D05_4565, ( 3471, 3474 )*'
      # 1435
      when 'D05_5391, D05_5395, D05_5396, D05-5397, D05_5398, D05_5399, D05_5400, ( 3112 )*'
        photo = 'D05_5391, D05_5395, D05_5396, D05_5397, D05_5398, D05_5399, D05_5400, ( 3112 )*'
      # 1711-1713
      when 'D05_4954, D05_4955, D05_4956, D05_4957, D05_4958, D05_4959, D05_4983 (Z 6), D05_4984, D05_4985, D05_4986, D05_4987, D05_4988'
        photo           = 'D05_4954, D05_4955, D05_4956, D05_4957, D05_4958, D05_4959, D05_4983, D05_4984, D05_4985, D05_4986, D05_4987, D05_4988'
        photo_kommentar = 'D05_4983 (Z 6)'
      # 1818-1820
      when 'D05_6097, D05_6098, D05_6100, D05_6101, D06_6102, D05_6103, D05_6104, D05_6105, D05_6106, D05_6107, D05_6108, D05_6109, D05_6110, D05_6111, D05_6112, D05_6113, D05_6114, D05_6115, D05_6299, D05_6300'
        photo = 'D05_6097, D05_6098, D05_6100, D05_6101, D05_6102, D05_6103, D05_6104, D05_6105, D05_6106, D05_6107, D05_6108, D05_6109, D05_6110, D05_6111, D05_6112, D05_6113, D05_6114, D05_6115, D05_6299, D05_6300'
      # 1837,1839
      when 'D05_6052, D05_6053, D05_6054, D05_6055, D06_6056, D05_6057, D05_6058, D05_6059, D06_6060, D05_6068, D05_6069, D05_6070, D05_6287'
        photo = 'D05_6052, D05_6053, D05_6054, D05_6055, D05_6056, D05_6057, D05_6058, D05_6059, D05_6060, D05_6068, D05_6069, D05_6070, D05_6287'
      # 1838
      when 'D05_6052, D05_6053, D05_6054, D05_6055, D06_6056, D05_6057, D05_6058, D05_6059, D06_6060, D05_6068, D05_6069, D05_6070, D05_6287, 3846, 3847, 3848'
        photo = 'D05_6052, D05_6053, D05_6054, D05_6055, D05_6056, D05_6057, D05_6058, D05_6059, D05_6060, D05_6068, D05_6069, D05_6070, D05_6287, 3846, 3847, 3848'
      # 1867-1869
      when 'D05_6017+, D05_6018, D05_6019, D05_6020, D05_6021, D05_6022, D05_6025, D05_6284+, D05_6285+, ( 1650 )*'
        photo = 'D05_6017, D05_6018, D05_6019, D05_6020, D05_6021, D05_6022, D05_6025, D05_6284, D05_6285, ( 1650 )*'
      # 3097-3099
      when 'D05_4160, D05_4161, D05_4162, D05_4163, D05_4164, D05_4165, D05_4166, D05, 4167, D05_4168, D05_4169'
        photo = 'D05_4160, D05_4161, D05_4162, D05_4163, D05_4164, D05_4165, D05_4166, D05_4167, D05_4168, D05_4169'
      # 3745
      when 'D03_0772, D03_0791, D03_0792, 1146, 1147, e015 ( 1145, 1340, 1341, E. XIII, pl. CCCCXCIV - CCCCXCVI )*'
        photo = 'D03_0772, D03_0791, D03_0792, 1146, 1147, e015 ( 1145, 1340, 1341, E. XIII, pl. CCCCXCIV, CCCCXCV, CCCXCVI )*'
      # 4077
      when 'D05_0388, D05_0389, D05_0390, D05_0391, D05_0392, D05_0393, D05_0394, D05-0395, D03_0622, D03_0623, D03_0624, D03_0625, D03_0618, D03_0619, D03_0620, D03_0621, 1446, 1447 (E. XIV, pl. DLII )*'
        photo = 'D05_0388, D05_0389, D05_0390, D05_0391, D05_0392, D05_0393, D05_0394, D05_0395, D03_0622, D03_0623, D03_0624, D03_0625, D03_0618, D03_0619, D03_0620, D03_0621, 1446, 1447 (E. XIV, pl. DLII )*'
      # 4127
      when 'D05_0539, D05_0540, D05_0541, D05_0542¸ D05_0543, D05_0544, D05_0545, D05_0546, D05_0553, D05_0554, D05_0555, 1449, 1450, e021'
        photo = 'D05_0539, D05_0540, D05_0541, D05_0542, D05_0543, D05_0544, D05_0545, D05_0546, D05_0553, D05_0554, D05_0555, 1449, 1450, e021'
      # 4202
      when 'D05_1876, D05-1877, D05_1878, D05_1893, 1418, 1419, 1420, e087 ( 1415, 1416, 1417, E. XIII, pl. DXX, DXXI )*'
        photo = 'D05_1876, D05_1877, D05_1878, D05_1893, 1418, 1419, 1420, e087 ( 1415, 1416, 1417, E. XIII, pl. DXX, DXXI )*'
      # 4227
      when 'D05_1954, D05_1955, D05_1962, D05_1963, 1409, 1408, e083 (E. XIII, DXXIV, DXXV )*'
        photo = 'D05_1954, D05_1955, D05_1962, D05_1963, 1409, 1408, e083 (E. XIII, pl. DXXIV, DXXV )*'
      # 4420
      when 'D05_1824, D05_1825, D05_1826, D05_1827, D05_1830, D05_1831, D05_1832, D05_1833, D05-1834, D05_1835, D05_1836, D05_1837, 1425, 1426, 1427, e090 (E. XIII, pl. DXXXVI )*'
        photo = 'D05_1824, D05_1825, D05_1826, D05_1827, D05_1830, D05_1831, D05_1832, D05_1833, D05_1834, D05_1835, D05_1836, D05_1837, 1425, 1426, 1427, e090 (E. XIII, pl. DXXXVI )*'

    end


    # 4772-4795
    # todo check why is here a float in photo?
    photo = photo.to_s.gsub(/D05_1061:/, 'D05_1061,')
    # 4817-4823
    photo = photo.gsub(/D05-0933/, 'D05_0933')
    # 9316-9323
    photo = photo.gsub(/2314 - 2316/, '2314, 2315, 2316')
    # 9332
    photo = photo.gsub(/2320 - 2322/, '2320, 2321, 2322')

    #elif Photo == '103, 105, 111, 112, 2372, 2387, 2560 ( 103 - 105, 2387 - 2390, E XIV, pl. DCLXXIV )*':

    # todo prüfen ob uid korrekt ist?
    # 10021
    if uid == 10021
      photo = '103, 105, 111, 112, 2372, 2387, 2560 ( 103, 104, 105, 2387, 2388, 2389, 2390, E. XIV, pl. DCLXXIV )*'
    end

    # 9741-9773
    if photo.match(/\( 2438, 2439, 2440, 2441, 2442, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2451 \(E. VIII, 96, 3 - 99, 3\)\)\*/)
      photo           = photo.gsub(/\( 2438, 2439, 2440, 2441, 2442, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2451 \(E. VIII, 96, 3 - 99, 3\)\)\*/,
                                   '( 2438, 2439, 2440, 2441, 2442, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2451 )*')
      photo_kommentar = 'E. VIII, 96, 3 - 99, 3'
    end

    # 8399, 9011, 9012
    if uid == 8399 or uid == 9011 or uid == 9012
      photo           = '3813, 3814, 3815, 3816, 3817, 3818, 3819, 3820, 3821, 3822, 3823, 3824, 3825, 3826, 3827, 3828, 3829, 3830, 3831, 3832, 3833, 3834, 3835, 3836, 3837, 3838'
      photo_kommentar = 'E. VII, 252, 5'
    end

    # 9950
    if uid == 9950
      photo           = photo.gsub(/\(E VIII, 122, 5 - 124, 18\)/, '')
      photo_kommentar = 'E VIII, 122, 5 - 124, 18'
    end

    # 5629-5650, 6135
    photo = photo.gsub(/E. E. /, 'E. ')

    # 6249, 6371-6373
    photo = photo.gsub(/E. XIV. /, 'E. XIV, ')

    # 10339, 10340
    photo = photo.gsub(/E. XIV /, 'E. XIV, ')


    # einige mit vergessenem . hinter dem E, z.B. 10203ff
    photo = photo.gsub(/E X/, 'E. X')

    # 10348-10372
    photo = photo.gsub(/\( 3909, 3910 \) \*/, '( 3909, 3910 )*')

    if origPhoto != photo
      logger.info "\t[INFO]  [FL] #{uid} Photo String veraendert, orginal: #{origPhoto} neu: #{photo}"
    end


    # Sonderfälle

    photo_name      = Array.new
    photo_typ       = Array.new
    photo_pfad      = Array.new
    photo_kommentar = Array.new

    photosDict   = {}
    photoTypDict = {
        'alt'                   => {'uid' => 0, 'name' => 'SW', 'jahr' => 1999},
        'D03'                   => {'uid' => 1, 'name' => '2003', 'jahr' => 2003},
        'D05'                   => {'uid' => 2, 'name' => '2005', 'jahr' => 2005},
        'e'                     => {'uid' => 3, 'name' => 'e', 'jahr' => 1900},
        'G'                     => {'uid' => 4, 'name' => 'G', 'jahr' => 1950},
        'e-o'                   => {'uid' => 5, 'name' => 'e-o', 'jahr' => 1960},
        'Labrique, Stylistique' => {'uid' => 6, 'name' => 'Labrique, Stylistique', 'jahr' => 1912},
        'E. XIII'               => {'uid' => 7, 'name' => 'Edfou XIII', 'jahr' => 1913},
        'E. XIV'                => {'uid' => 8, 'name' => 'Edfou XIV', 'jahr' => 1914},
    }

    re1  = Regexp.new('[0-9]+a*')
    re2  = Regexp.new('D03_[0-9]+')
    re3  = Regexp.new('D05_[0-9]+a*')
    re4  = Regexp.new('e[0-9]+')
    re5  = Regexp.new('(E. [XVI]+), (pl. [DCLXVI0-9]+)')
    re6  = Regexp.new('\([^)]*\)(\s*\**)')
    re7  = Regexp.new('[DCLXVI]+')
    re8  = Regexp.new('\)\s*\**')
    re9  = Regexp.new('(G[0-9]+)\s*([f.]*)') # Z.B. G30 oder G32 ff.
    re10 = Regexp.new('e-onr-[0-9]+')
    re11 = Regexp.new(';*\s*Labrique, Stylistique, (pl. [0-9.]*)')
    re12 = Regexp.new('\s*\*') # beginnt mit beliebiege whitesp. und '*'
    re13 = Regexp.new('\s*\(teilweise\)')
    re14 = Regexp.new('([^)]*)\s*(\(E. [IVX]+, [0-9]+, [-0-9]+\))(.*)')
    re15 = Regexp.new('[^(]*\((E.[^)]*)')


    bildString = photo
    klammern   = false
    stern      = false

    while bildString.size > 0


      name      = ''
      typ       = '---'
      pfad      = ''
      kommentar = ''

      if uid == 9562
        if bildString.match('VIII')
          m15       = re15.match(bildString)
          kommentar = m15[1]
        else
          kommentar = ''
        end
      end

      if  re6.match(bildString)

        # todo: finishCollection(PRIMARY) nicht impl., wirklich benötigt? scheinbar nur für Normalisierung

        # Klammern auf, ggf mit einem Stern hinter der schließenden Klammer
        klammern = true

        # gematched bei 'einem' Stern hinter der schließenden Klammer
        if (re6.match(bildString))[1] == '*'
          stern = true
        end


        # öffnende Klammer (am Anfang) weg
        bildString = bildString[1..-1]

        # Spezielfälle mit Kommentieren

        m14        = re14.match(bildString)

        if m14 and uid < 9000
          # 6344-6356
          bildString = m14[1] + m14[3]
          kommentar  = m14[2]

        elsif uid == 9834
          bildString = '3911 )*'
          kommentar  = 'E. VIII, 108, nach 3'

        elsif uid == 9951
          bildString = '2374, 2375, 2376 )*'
          kommentar  = 'E VIII, 122, 5 - 124, 18'

        elsif uid == 9562 and bildString.match('VIII')
          # hinter schließenden klammer weiter
          bildString = bildString[(bildString.index(')') + 1)..-1]
          klammern   = false

        elsif uid == 9671
          kommentar  = 'E. VIII, 87, 5'
          bildString = '141, 142, E. XIV, pl. DCLXIX, DCLXX )*'

        elsif uid == 9870
          kommentar  = 'E. VIII, 111, 16'
          bildString = '114, 115, 116, 117)*'

        end

      elsif re8.match(bildString)
        # Klammer zu
        klammern   = false
        bildString = bildString[((re8.match(bildString)[0]).length)..-1]

      elsif re2.match(bildString)
        # Fall 2: Dateiname der Form D03_XXXXX
        name       = re2.match(bildString)[0]
        typ        = 'D03'
        bildString = bildString[(name.length)..-1]

      elsif re3.match(bildString)
        # Fall 3: Dateiname der Form D05_XXXXX
        name       = re3.match(bildString)[0]
        typ        = 'D05'
        bildString = bildString[(name.length)..-1]

      elsif re4.match(bildString)
        # Fall 4: Dateiname der Form eXXX
        name       = re4.match(bildString)[0]
        typ        = 'e'
        bildString = bildString[(name.length)..-1]

      elsif re9.match(bildString)
        # Fall 5: Name der Form GXXX [ff.]
        name       = re9.match(bildString)[1]
        typ        = 'G'
        kommentar  = re9.match(bildString)[2]
        bildString = bildString[((re9.match(bildString)[0]).length)..-1]

      elsif re10.match(bildString)
        # Fall 6: Name der Form e-onr-XXX
        name       = re10.match(bildString)[0]
        typ        = 'e-o'
        bildString = bildString[(name.length)..-1]

      elsif re1.match(bildString)
        # Fall 1: Dateiname nur aus Ziffern (am Ende beliebig viele 'a')
        # name = erstes Auftreten des match
        name       = re1.match(bildString)[0]
        typ        = 'alt'
        # schneidet aktuelle zahl vorn ab
        #
        bildString = bildString[(name.length)..-1]


      elsif re11.match(bildString)
        # Fall 7: Labrique, Stylistique
        name       = re11.match(bildString)[1]
        typ        = 'Labrique, Stylistique'
        bildString = bildString[((re11.match(bildString)[0]).length)..-1]

      elsif re5.match(bildString)
        # Fall (n+1): Verweis auf Tafeln im Edfou Buch
        m          = re5.match(bildString)
        typ        = m[1]
        name       = m[2]
        # rest = m.group(3)

        # kombi aus strip & führendes/endende Komma abschneiden
        bildString = bildString[((m[0]).length)..-1].strip.sub(',', '').strip #match(/(^\s*,\s*)(.*)(\s*,\s*$)/)[2]

        if re7.match(bildString)
          # Es kommt noch ein Edfou Bild
          bildString = typ + ', pl. ' + bildString
        end
      else
        logger.warn "\t[WARN]  [FL] uid: #{uid} unklarer String:  #{:bildString}"
        bildString = ''
      end

      if (name.length) > 0

        if re12.match(bildString)
          # ist gefolgt von *
          # prüfen, matched auch ohne *
          stern      = true
          bildString = bildString[((re12.match(bildString))[0]).length..-1]
        end

        if re13.match(bildString)
          kommentar  = 'teilweise'
          bildString = bildString[(re13.match(bildString)[0]).length..-1]
        end

        if uid == 9910 and bildString.match('103')
          kommentar  = 'E. VIII, 118, 7'
          bildString = ''
        end


        pfad = "#{typ}/#{name}"

        if photo_kommentar
          if kommentar
            kommentar = "#{photo_kommentar}; #{kommentar}"
          else
            kommentar = photo_kommentar
          end
        else
          kommentar = photo_kommentar
        end

        # todo ggf. in array sammeln und als batch speichern
        p = Photo.fetch(
            pfad,
            name,
            typ,
            kommentar
        )

        if p.class == Array
          p = p[0]
          photos << p
        end

        formular.photos << p unless formular.photos.include? p

      end


      bildString = bildString.strip.sub(',', '').strip # m[2]

    end


    # todo: finishCollection(PRIMARY) nicht impl., wirklich benötigt? scheinbar nur für Normalisierung
    # finishCollection(PRIMARY)

    return photos

  end


# korrigiert bekannte Fehler
  def check_uebersetzungs_string(uebersetzung, uid)

    origUebers = uebersetzung

    uebersetzung = uebersetzung.strip
                       .gsub(/dZtruit/, 'détruit')
                       .gsub(/enti\?rement/, 'entièrement')
                       .gsub(/moitiZ/, 'moitié')
                       .gsub(/premi\?re/, 'première')
                       .gsub(/placZe/, 'placée')
                       .gsub(/dZesse/, 'déesse')
                       .gsub(/mutilZs/, 'mutilés')
                       .gsub(/fen\?tre/, 'fenêtre')
                       .gsub(/ZtZ gravZe/, 'été gravée')

    if  uebersetzung != origUebers
      logger.info "\t[INFO]  [FL] uid: #{uid} String der Übersetzung verändert, von: #{origUebers} auf: #{uebersetzung}"
    end

    # log wenn 'Z' in Ort auftritt oder ein Fragezeichen

    re101 = Regexp.new('\wZ')
    re102 = Regexp.new('\w\?\w')

    #if self[:uebersetzung].scan re101 or self[:uebersetzung].scan re102
    # ergebnis von scan ist ungeeignet, da es ggf. ein leeres array liefert, also nie false ist
    if uebersetzung.match re101 or uebersetzung.match re102
      logger.warn "\t[WARN]  [FL] uid: #{uid} Vermutlich kaputte Akzente, übersetzung: #{uebersetzung}"
    end

    return uebersetzung
  end

end
