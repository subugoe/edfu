# encoding: utf-8

module VerifyFormularHelper
  include EdfuDataMappings

  private

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

        formular.literaturen << lit unless formular.literaturen.include? lit

      }
    end

    return literaturen
  end


  def create_stellen(seitezeile, band, uid)

    anmerkung = ''

    freigegeben = banddict((band).to_i, 'freigegeben')


    ## Sonderfälle
    szOriginal  = seitezeile


    if seitezeile.index('nach ') == 0
      anmerkung  = seitezeile
      seitezeile = seitezeile.gsub('nach ', '')
    end

    if seitezeile.index(', Z') != nil
      anmerkung  = seitezeile
      seitezeile = seitezeile[0..seitezeile.index(', Z')]
    end

    if seitezeile.index(' / Z') != nil
      anmerkung  = seitezeile
      seitezeile = seitezeile[0..seitezeile.index(' / Z')]
    end

    if seitezeile.index(', Kol') != nil
      anmerkung = seitezeile
      seitezeile= seitezeile[0..seitezeile.index(', Kol')]
    end

    if seitezeile.index(' / kol') != nil
      anmerkung = seitezeile
      seitezeile= seitezeile[0..seitezeile.index(' / kol')]
    end

    if seitezeile.index(' / ') != nil
      anmerkung = seitezeile
      seitezeile= seitezeile[0..seitezeile.index(' / ')]
    end

    if szOriginal != seitezeile

      if seitezeile == szOriginal
        Edfulog.new("ERROR", "FL", "Änderung an Seitezeile", "SEITEZEILE", szOriginal, seitezeile, uid)
      end


    end

    if (seitezeile.scan(/[^0-9, -]/)).length > 0
      Edfulog.new("INFO", "FL", "Evtl. Fehlerhafte Seitezeile", "SEITEZEILE", szOriginal, '', uid)
    end

    result = []

    seitezeile    = seitezeile
    band_roemisch = dezimal_nach_roemisch(band)


    if seitezeile.index(' - ') != nil # mit leerzeichen  bsp: 002, 06 - 003, 02
      szParts = seitezeile.split(' - ') # ["002, 06", "003, 02"]

      begin
        result << szSplit(szParts[0]) # ["002, 06"]
        result << szSplit(szParts[1]) # ["003, 02"]
      rescue ArgumentError
        Edfulog.new("ERROR", "FL", "Seitezeile konnte nicht gesplittet werden (alles auf 0)", "SEITEZEILE", szOriginal, '', uid)
        result = [[0, 0], [0, 0]]
      end


    elsif seitezeile.index(',') != nil # ohne leerzeichen  bsp: 008, 08-09
      parts = seitezeile.split(',') # ["008", " 08-09"]
      seite = (parts[0]).to_i # 008
      if (parts[1] != nil) and (parts[1].index('-') != nil)
        zeilen = parts[1].split('-') # ["08","09"]
        result = [[seite, (zeilen[0]).to_i], [seite, (zeilen[1]).to_i]] # [[008,08],[008,09]]
      else
        zeile  = (parts[1]).to_i
        result = [[seite, zeile], [seite, zeile]]
      end
    else
      result = [[0, 0], [0, 0]]
      Edfulog.new("ERROR", "FL", "Fehlerhafte Seitezeile", "SEITEZEILE", szOriginal, '', uid)
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
      Edfulog.new("ERROR", "FL", "Fehlerhafte Seitezeile (Seiten absteigend)", "SEITEZEILE", szOriginal, '', uid)
    end

    if result[0][0] == result[1][0] and result[0][1] > result[1][1]
      Edfulog.new("ERROR", "FL", "Fehlerhafte Seitezeile (Zeilen absteigend)", "SEITEZEILE", szOriginal, '', uid)
    end

    seite_start = result[0][0]
    zeile_start = result[0][1]
    seite_stop  = result[1][0]
    zeile_stop  = result[1][1]

    if zeile_start > 30
      Edfulog.new("ERROR", "FL", "Fehlerhafte Seitezeile (Start > 30)", "SEITEZEILE", szOriginal, '', uid)
    end

    if zeile_stop > 30
      Edfulog.new("ERROR", "FL", "Fehlerhafte Seitezeile (Stop > 30)", "SEITEZEILE", szOriginal, '', uid)
    end

    stop_unsicher = false
    zerstoerung   = false

    stelle = Stelle.fetch(
        "formular",
        'Edfu',
        band,
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
        photo = 'D05_4954, D05_4955, D05_4956, D05_4957, D05_4958, D05_4959, D05_4983, D05_4984, D05_4985, D05_4986, D05_4987, D05_4988'
      #photo_kommentar = 'D05_4983 (Z 6)'
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
    photo = photo.to_s.gsub(/D05_1061:/, 'D05_1061,')
    # 4817-4823
    photo = photo.gsub(/D05-0933/, 'D05_0933')
    # 9316-9323
    photo = photo.gsub(/2314 - 2316/, '2314, 2315, 2316')
    # 9332
    photo = photo.gsub(/2320 - 2322/, '2320, 2321, 2322')

    #elif Photo == '103, 105, 111, 112, 2372, 2387, 2560 ( 103 - 105, 2387 - 2390, E XIV, pl. DCLXXIV )*':


    # 9741-9773
    if photo.match(/\( 2438, 2439, 2440, 2441, 2442, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2451 \(E. VIII, 96, 3 - 99, 3\)\)\*/)
      photo = photo.gsub(/\( 2438, 2439, 2440, 2441, 2442, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2451 \(E. VIII, 96, 3 - 99, 3\)\)\*/,
                         '( 2438, 2439, 2440, 2441, 2442, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2451 )*')
      #photo_kommentar = 'E. VIII, 96, 3 - 99, 3'
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
      Edfulog.new("ERROR", "FL", "Änderung an Photostring", "Photo", origPhoto, photo, uid)
    end


    # Sonderfälle


    photosDict = {}

    re1  = Regexp.new('^[0-9]+a*')
    re2  = Regexp.new('^D03_[0-9]+')
    re3  = Regexp.new('^D05_[0-9]+a*')
    re4  = Regexp.new('^e[0-9]+')
    re5  = Regexp.new('^(E. [XVI]+), ([pl. ]*[DCLXVI0-9]+)')
    re6  = Regexp.new('^\([^)]*\)(\s*\**)')
    re7  = Regexp.new('^[DCLXVI]+')
    re8  = Regexp.new('^\)\s*\**')
    re9  = Regexp.new('^(G[0-9]+)\s*([f.]*)') # Z.B. G30 oder G32 ff.
    re10 = Regexp.new('^e-onr-[0-9]+')
    re11 = Regexp.new('^;*\s*Labrique, Stylistique, (pl. [0-9.]*)')
    re12 = Regexp.new('^\s*\*') # beginnt mit beliebiege whitesp. und '*'
    re13 = Regexp.new('^\s*\(teilweise\)')
    re14 = Regexp.new('^([^)]*)\s*(\(E. [IVX]+, [0-9]+, [-0-9]+\))(.*)')
    re15 = Regexp.new('^[^(]*\((E.[^)]*)')


    bildString = photo
    klammern   = false
    stern      = false

    while bildString.size > 0

      name      = ''
      typ       = '---'
      pfad      = ''
      kommentar = ''



      if  re6.match(bildString)


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
        m  = re5.match(bildString)
        m2 = m[2]

        unless m[2].include?("pl. ")
          m2 = "pl. #{m[2]}"
        end

        typ        = m[1]
        name       = m2
        # rest = m.group(3)

        # kombi aus strip & führendes/endende Komma abschneiden
        #
        bildString = bildString[((m[0]).length)..-1].strip.sub(',', '').strip #match(/(^\s*,\s*)(.*)(\s*,\s*$)/)[2]

        if re7.match(bildString)
          # Es kommt noch ein Edfou Bild
          bildString = typ + ', pl. ' + bildString
        end
      else

        pos = bildString.index(",")

        Edfulog.new("ERROR", "FL", "Keine Abbildungsregel für #{bildString[0...pos]}", "Photo", origPhoto, '', uid)


        bildString = bildString[pos..-1]

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



        typ  = photoTypDict[typ]['name']
        pfad = "#{typ}/#{name}"

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


      bildString = bildString.strip.sub(/^[,.:\s]*/, '').strip # m[2]

    end

    return photos

  end


# korrigiert bekannte Fehler
  def check_uebersetzungs_string(uebersetzung, uid)

    origUebers = uebersetzung

    uebersetzung = uebersetzung
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
      Edfulog.new("INFO", "FL", "Evtl. Fehler in Übersetzung", "TEXTDEUTSC", origUebers, uebersetzung, uid)
    end

    # log wenn 'Z' in Ort auftritt oder ein Fragezeichen
    re101 = Regexp.new('\wZ')
    re102 = Regexp.new('\w\?\w')

    if (uebersetzung.match(re101) || uebersetzung.match(re102))
      Edfulog.new("INFO", "FL", "'Z' oder '?' innerhalb eines Wortes", "TEXTDEUTSC", origUebers, uebersetzung, uid)
    end

    return uebersetzung
  end

  def szSplit(s)
    parts = s.gsub(' ', '').split(',')
    parts = [(parts[0]).to_i, (parts[1]).to_i]

    return parts
  end

end
