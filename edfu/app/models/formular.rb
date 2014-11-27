# encoding: utf-8


class Formular < ActiveRecord::Base
  has_many :stellen, as: :zugehoerigZu

  # after_update :log_updated
  # after_create :log_created
  before_validation :check_data


  searchable do


    integer :uid, stored: true
    text :transliteration, stored: true # todo transliteration_highlight hinzufügen
    text :transliteration_nosuffix, stored: true
    text :uebersetzung, stored: true
    text :texttyp, stored: true
    text :photo, stored: true # todo photo_highlight hinzufügen
    text :photo_pfad, stored: true
    text :photo_kommentar, stored: true
    integer :szeneID, stored: true
    text :literatur, stored: true
    integer :band, stored: true
    text :seitezeile, stored: true
    # todo stelle_id und attr. aus Stelle hinzufügen, und bandseitezeile_highlight hinzufügen
    # todo id hinzufügen, typ hinzufügen,

  end


  # # set default value if nil
  # def transliteration
  #   self[:transliteration] || ''
  # end
  #
  # # set default value if nil
  # def transliteration_nosuffix
  #   self[:transliteration_nosuffix] || ''
  # end
  #
  # # set default value if nil
  # def uebersetzung
  #   self[:uebersetzung] || ''
  # end
  #
  # # set default value if nil
  # def texttyp
  #   self[:texttyp] || ''
  # end
  #
  # # set default value if nil
  # def photo
  #   self[:photo] || ''
  # end
  #
  # # set default value if nil
  # def photo_pfad
  #   self[:photo_pfad] || ''
  # end
  #
  # # set default value if nil
  # def photo_kommentar
  #   self[:photo_kommentar] || ''
  # end
  #
  # # set default value if nil
  # def szeneID
  #   self[:szeneID] || -1
  # end
  #
  # # set default value if nil
  # def literatur
  #   self[:literatur] || ''
  # end
  #
  # # set default value if nil
  # def band
  #   self[:band] || -1
  # end
  #
  # # set default value if nil
  # def seitezeile
  #   self[:seitezeile] || ''
  # end


  private


  # todo aufräumen, d.h. code in module/helper





  def check_data

    @myFormular = Hash.new
    @formularDict = Hash.new

    check_uebersetzung_re_1
    check_uebersetzung_re_2
    check_transliteration_re_3
    check_photo_re_4
    check_photo_re_5
    check_textposition_re_6

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


  # todo
  def create_photo_pfad(photo)

  end

  # todo
  def create_photo_commentar(photo)

  end



  # bekannte Fehler in uebersetzung und Änderung loggen
  def check_uebersetzung_re_1

    @myFormular['uid'] = Integer(self[:uid])

    # Felder
    @myFormular['texttyp'] = self[:texttyp]


    @myFormular['uebersetzung'] = self[:uebersetzung].strip
    .gsub(/dZtruit/, 'détruit')
    .gsub(/enti\?rement/, 'entièrement')
    .gsub(/moitiZ/, 'moitié')
    .gsub(/premi\?re/, 'première')
    .gsub(/placZe/, 'placée')
    .gsub(/dZesse/, 'déesse')
    .gsub(/mutilZs/, 'mutilés')
    .gsub(/fen\?tre/, 'fenêtre')
    .gsub(/ZtZ gravZe/, 'été gravée')

    if  @myFormular['uebersetzung'] != self[:uebersetzung]
      logger.info "\t[INFO]  [FL] uid: #{self[:uid]} String der Übersetzung verändert, von: #{self[:uebersetzung]} auf: #{@myFormular['uebersetzung']}"
      self[:uebersetzung] = @myFormular['uebersetzung']
    end

  end

  # log wenn 'Z' in Ort auftritt oder ein Fragezeichen
  def check_uebersetzung_re_2

    re101 = Regexp.new('\wZ')
    re102 = Regexp.new('\w\?\w')

    #if self[:uebersetzung].scan re101 or self[:uebersetzung].scan re102
    # ergebnis von scan ist ungeeignet, da es ggf. ein leeres array liefert, also nie false ist
    if self[:uebersetzung].match re101 or self[:uebersetzung].match re102
      logger.warn "\t[WARN]  [FL] uid: #{self[:uid]} Vermutlich kaputte Akzente, übersetzung: #{self[:uebersetzung]}"
    end

  end

  # todo was ist beabsichtigt im concert.py
  def check_transliteration_re_3

  end

  def check_photo_re_4

    photo = self[:photo]


    case photo
      # 263
      when 'D05_5503, D05_5504, D05_5509, D05_5510, D05_5511, D05_5512: D05_5513, D05_5514, ( 2982, 2983, 2984, 2985 )*'
        self[:photo] = 'D05_5503, D05_5504, D05_5509, D05_5510, D05_5511, D05_5512, D05_5513, D05_5514, ( 2982, 2983, 2984, 2985 )*'
      # 409
      when 'D05_6555, D06_6556, D05_6557, D05_6558, D05_6559, D05_6560, D05_6561, ( 1605, 1606 )*'
        self[:photo] = 'D05_6555, D05_6556, D05_6557, D05_6558, D05_6559, D05_6560, D05_6561, ( 1605, 1606 )*'
      # 1137-1138
      when 'D05_4151, D05_4152, D05_4153, D05_4160: D05_4161, D05_4162, D05_4163, D05_4164, D05_4165, D05_4166, D05_4167, D05_4168, D05_4169, ( 1615, 1616 )*'
        self[:photo] = 'D05_4151, D05_4152, D05_4153, D05_4160, D05_4161, D05_4162, D05_4163, D05_4164, D05_4165, D05_4166, D05_4167, D05_4168, D05_4169, ( 1615, 1616 )*'
      # 1155-1156
      when 'D05_3779, D05_3780, D05_3787, D05_3788, D05_3789, D05_3790, D05_3791, D05_3792, D05_3793, D05_3794, D05_3795, D05_3796, D05_4094, D05_:4095, D05_4102, D05_4103, D05_4104: D05_4105, D05_4106, D05_4107, D05_4108, D05_4109, ( 1616, 1617 )*'
        self[:photo] = 'D05_3779, D05_3780, D05_3787, D05_3788, D05_3789, D05_3790, D05_3791, D05_3792, D05_3793, D05_3794, D05_3795, D05_3796, D05_4094, D05_4095, D05_4102, D05_4103, D05_4104, D05_4105, D05_4106, D05_4107, D05_4108, D05_4109, ( 1616, 1617 )*'
      # 1157-1159
      when 'D05_3771, D05_3772, D05_3773, D05_3774, D05-3775, D05_3776, D05_3777, D05_3778, D05_3779, D05_3780, D05_3783, D05_3784, D05_3786, D05_4085, D05_4086, D05_4087, D05_4088, D05_4089, D05_4090, D05_4091, D05_4092, D05_4093, D05_4094, D05_4095, D05_4099, D05_4100, D05_4101, ( 1616, 1617 )*'
        self[:photo] = 'D05_3771, D05_3772, D05_3773, D05_3774, D05_3775, D05_3776, D05_3777, D05_3778, D05_3779, D05_3780, D05_3783, D05_3784, D05_3786, D05_4085, D05_4086, D05_4087, D05_4088, D05_4089, D05_4090, D05_4091, D05_4092, D05_4093, D05_4094, D05_4095, D05_4099, D05_4100, D05_4101, ( 1616, 1617 )*'
      # 1163-1165
      when 'D05_3764, D05_3765, D05_3766, D05_3767, D05_3768, D05_3769, D05_3770, D05_4068, D05_4069, D05_4070, D05_4071, D05_4072, D05_4073, D04_4074, D05_4075, D05_4076, D05_4077, D05_4078, D05_4079, D05_4080, D05_4081, D05_4082, D05_4083, D05_4084, ( 1617, 1618, 1619 )*'
        self[:photo] = 'D05_3764, D05_3765, D05_3766, D05_3767, D05_3768, D05_3769, D05_3770, D05_4068, D05_4069, D05_4070, D05_4071, D05_4072, D05_4073, D05_4074, D05_4075, D05_4076, D05_4077, D05_4078, D05_4079, D05_4080, D05_4081, D05_4082, D05_4083, D05_4084, ( 1617, 1618, 1619 )*'
      # 1167-1169
      when 'D05_3764, D05_3765, D05_3766, D05_3767, D05_3768, D05_3769, D05_3770, D05_4068, D05_4069, D05_4070, D05_4071, D05_4072, D05_4073, D04_4074, D05_4075, ( 1618, 1619, 1620 )*'
        self[:photo] = 'D05_3764, D05_3765, D05_3766, D05_3767, D05_3768, D05_3769, D05_3770, D05_4068, D05_4069, D05_4070, D05_4071, D05_4072, D05_4073, D05_4074, D05_4075, ( 1618, 1619, 1620 )*'
      # 1381-1382
      when 'D05_3678, D05_3822, D05_3823, D05_3824, D05_3825, D05_3826, D05_3827, D05_3828, D05_3829, D05_3830, D05_3831, D05_3832, D05_3833, D05_4297, D05_4298, D05_4299, D05_4300, D05_4301, D05_4302, D05_4560, D05_4561, D05-4562, D05_4563, D05_4564, D05_4565, ( 3471, 3474 )*'
        self[:photo] = 'D05_3678, D05_3822, D05_3823, D05_3824, D05_3825, D05_3826, D05_3827, D05_3828, D05_3829, D05_3830, D05_3831, D05_3832, D05_3833, D05_4297, D05_4298, D05_4299, D05_4300, D05_4301, D05_4302, D05_4560, D05_4561, D05_4562, D05_4563, D05_4564, D05_4565, ( 3471, 3474 )*'
      # 1435
      when 'D05_5391, D05_5395, D05_5396, D05-5397, D05_5398, D05_5399, D05_5400, ( 3112 )*'
        self[:photo] = 'D05_5391, D05_5395, D05_5396, D05_5397, D05_5398, D05_5399, D05_5400, ( 3112 )*'
      # 1711-1713
      when 'D05_4954, D05_4955, D05_4956, D05_4957, D05_4958, D05_4959, D05_4983 (Z 6), D05_4984, D05_4985, D05_4986, D05_4987, D05_4988'
        self[:photo] = 'D05_4954, D05_4955, D05_4956, D05_4957, D05_4958, D05_4959, D05_4983, D05_4984, D05_4985, D05_4986, D05_4987, D05_4988'
        self[:photo_kommentar] = 'D05_4983 (Z 6)'
      # 1818-1820
      when 'D05_6097, D05_6098, D05_6100, D05_6101, D06_6102, D05_6103, D05_6104, D05_6105, D05_6106, D05_6107, D05_6108, D05_6109, D05_6110, D05_6111, D05_6112, D05_6113, D05_6114, D05_6115, D05_6299, D05_6300'
        self[:photo] = 'D05_6097, D05_6098, D05_6100, D05_6101, D05_6102, D05_6103, D05_6104, D05_6105, D05_6106, D05_6107, D05_6108, D05_6109, D05_6110, D05_6111, D05_6112, D05_6113, D05_6114, D05_6115, D05_6299, D05_6300'
      # 1837,1839
      when 'D05_6052, D05_6053, D05_6054, D05_6055, D06_6056, D05_6057, D05_6058, D05_6059, D06_6060, D05_6068, D05_6069, D05_6070, D05_6287'
        self[:photo] = 'D05_6052, D05_6053, D05_6054, D05_6055, D05_6056, D05_6057, D05_6058, D05_6059, D05_6060, D05_6068, D05_6069, D05_6070, D05_6287'
      # 1838
      when 'D05_6052, D05_6053, D05_6054, D05_6055, D06_6056, D05_6057, D05_6058, D05_6059, D06_6060, D05_6068, D05_6069, D05_6070, D05_6287, 3846, 3847, 3848'
        self[:photo] = 'D05_6052, D05_6053, D05_6054, D05_6055, D05_6056, D05_6057, D05_6058, D05_6059, D05_6060, D05_6068, D05_6069, D05_6070, D05_6287, 3846, 3847, 3848'
      # 1867-1869
      when 'D05_6017+, D05_6018, D05_6019, D05_6020, D05_6021, D05_6022, D05_6025, D05_6284+, D05_6285+, ( 1650 )*'
        self[:photo] = 'D05_6017, D05_6018, D05_6019, D05_6020, D05_6021, D05_6022, D05_6025, D05_6284, D05_6285, ( 1650 )*'
      # 3097-3099
      when 'D05_4160, D05_4161, D05_4162, D05_4163, D05_4164, D05_4165, D05_4166, D05, 4167, D05_4168, D05_4169'
        self[:photo] = 'D05_4160, D05_4161, D05_4162, D05_4163, D05_4164, D05_4165, D05_4166, D05_4167, D05_4168, D05_4169'
      # 3745
      when 'D03_0772, D03_0791, D03_0792, 1146, 1147, e015 ( 1145, 1340, 1341, E. XIII, pl. CCCCXCIV - CCCCXCVI )*'
        self[:photo] = 'D03_0772, D03_0791, D03_0792, 1146, 1147, e015 ( 1145, 1340, 1341, E. XIII, pl. CCCCXCIV, CCCCXCV, CCCXCVI )*'
      # 4077
      when 'D05_0388, D05_0389, D05_0390, D05_0391, D05_0392, D05_0393, D05_0394, D05-0395, D03_0622, D03_0623, D03_0624, D03_0625, D03_0618, D03_0619, D03_0620, D03_0621, 1446, 1447 (E. XIV, pl. DLII )*'
        self[:photo] = 'D05_0388, D05_0389, D05_0390, D05_0391, D05_0392, D05_0393, D05_0394, D05_0395, D03_0622, D03_0623, D03_0624, D03_0625, D03_0618, D03_0619, D03_0620, D03_0621, 1446, 1447 (E. XIV, pl. DLII )*'
      # 4127
      when 'D05_0539, D05_0540, D05_0541, D05_0542¸ D05_0543, D05_0544, D05_0545, D05_0546, D05_0553, D05_0554, D05_0555, 1449, 1450, e021'
        self[:photo] = 'D05_0539, D05_0540, D05_0541, D05_0542, D05_0543, D05_0544, D05_0545, D05_0546, D05_0553, D05_0554, D05_0555, 1449, 1450, e021'
      # 4202
      when 'D05_1876, D05-1877, D05_1878, D05_1893, 1418, 1419, 1420, e087 ( 1415, 1416, 1417, E. XIII, pl. DXX, DXXI )*'
        self[:photo] = 'D05_1876, D05_1877, D05_1878, D05_1893, 1418, 1419, 1420, e087 ( 1415, 1416, 1417, E. XIII, pl. DXX, DXXI )*'
      # 4227
      when 'D05_1954, D05_1955, D05_1962, D05_1963, 1409, 1408, e083 (E. XIII, DXXIV, DXXV )*'
        self[:photo] = 'D05_1954, D05_1955, D05_1962, D05_1963, 1409, 1408, e083 (E. XIII, pl. DXXIV, DXXV )*'
      # 4420
      when 'D05_1824, D05_1825, D05_1826, D05_1827, D05_1830, D05_1831, D05_1832, D05_1833, D05-1834, D05_1835, D05_1836, D05_1837, 1425, 1426, 1427, e090 (E. XIII, pl. DXXXVI )*'
        self[:photo] = 'D05_1824, D05_1825, D05_1826, D05_1827, D05_1830, D05_1831, D05_1832, D05_1833, D05_1834, D05_1835, D05_1836, D05_1837, 1425, 1426, 1427, e090 (E. XIII, pl. DXXXVI )*'

    end


    # 4772-4795
    self[:photo].gsub(/D05_1061:/, 'D05_1061,')
    # 4817-4823
    self[:photo].gsub(/D05-0933/, 'D05_0933')
    # 9316-9323
    self[:photo].gsub(/2314 - 2316/, '2314, 2315, 2316')
    # 9332
    self[:photo].gsub(/2320 - 2322/, '2320, 2321, 2322')

    #elif Photo == '103, 105, 111, 112, 2372, 2387, 2560 ( 103 - 105, 2387 - 2390, E XIV, pl. DCLXXIV )*':

    # todo prüfen ob uid korrekt ist?
    # 10021
    if self[:uid] == 10021
      self[:photo] = '103, 105, 111, 112, 2372, 2387, 2560 ( 103, 104, 105, 2387, 2388, 2389, 2390, E. XIV, pl. DCLXXIV )*'
    end

    # 9741-9773
    if self[:photo].match(/\( 2438, 2439, 2440, 2441, 2442, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2451 \(E. VIII, 96, 3 - 99, 3\)\)\*/)
      self[:photo].gsub(/\( 2438, 2439, 2440, 2441, 2442, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2451 \(E. VIII, 96, 3 - 99, 3\)\)\*/,
                        '( 2438, 2439, 2440, 2441, 2442, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2451 )*')
      self[:photo_kommentar] = 'E. VIII, 96, 3 - 99, 3'
    end

    # 8399, 9011, 9012
    if self[:uid] == 8399 or self[:uid] == 9011 or self[:uid] == 9012
      self[:photo] = '3813, 3814, 3815, 3816, 3817, 3818, 3819, 3820, 3821, 3822, 3823, 3824, 3825, 3826, 3827, 3828, 3829, 3830, 3831, 3832, 3833, 3834, 3835, 3836, 3837, 3838'
      self[:photo_kommentar] = 'E. VII, 252, 5'
    end

    # 9950
    if self[:uid] == 9950
      self[:photo].gsub(/\(E VIII, 122, 5 - 124, 18\)/, '')
      self[:photo_kommentar] = 'E VIII, 122, 5 - 124, 18'
    end

    # 5629-5650, 6135
    self[:photo].gsub(/E. E. /, 'E. ')

    # 6249, 6371-6373
    self[:photo].gsub(/E. XIV. /, 'E. XIV, ')

    # 10339, 10340
    self[:photo].gsub(/E. XIV /, 'E. XIV, ')


    # einige mit vergessenem . hinter dem E, z.B. 10203ff
    self[:photo].gsub(/E X/, 'E. X')

    # 10348-10372
    self[:photo].gsub(/\( 3909, 3910 \) \*/, '( 3909, 3910 )*')

    if photo != self[:photo]
      logger.info "\t[INFO]  [FL] #{self[:uid]} Photo String veraendert, orginal: #{self[:photo]} neu: #{self[:photo]}"
    end
  end

  # Sonderfälle
  def check_photo_re_5

    photosDict = {}
    photo = []
    photo_typ = []
    photoTypDict = {
        'alt' => {'uid' => 0, 'name' => 'SW', 'jahr' => 1999},
        'D03' => {'uid' => 1, 'name' => '2003', 'jahr' => 2003},
        'D05' => {'uid' => 2, 'name' => '2005', 'jahr' => 2005},
        'e' => {'uid' => 3, 'name' => 'e', 'jahr' => 1900},
        'G' => {'uid' => 4, 'name' => 'G', 'jahr' => 1950},
        'e-o' => {'uid' => 5, 'name' => 'e-o', 'jahr' => 1960},
        'Labrique, Stylistique' => {'uid' => 6, 'name' => 'Labrique, Stylistique', 'jahr' => 1912},
        'E. XIII' => {'uid' => 7, 'name' => 'Edfou XIII', 'jahr' => 1913},
        'E. XIV' => {'uid' => 8, 'name' => 'Edfou XIV', 'jahr' => 1914},
    }

    re1 = Regexp.new('[0-9]+a*')
    re2 = Regexp.new('D03_[0-9]+')
    re3 = Regexp.new('D05_[0-9]+a*')
    re4 = Regexp.new('e[0-9]+')
    re5 = Regexp.new('(E. [XVI]+), (pl. [DCLXVI0-9]+)')
    re6 = Regexp.new('\([^)]*\)(\s*\**)')
    re7 = Regexp.new('[DCLXVI]+')
    re8 = Regexp.new('\)\s*\**')
    re9 = Regexp.new('(G[0-9]+)\s*([f.]*)') # Z.B. G30 oder G32 ff.
    re10 = Regexp.new('e-onr-[0-9]+')
    re11 = Regexp.new(';*\s*Labrique, Stylistique, (pl. [0-9.]*)')
    re12 = Regexp.new('\s*\*') # beginnt mit *
    re13 = Regexp.new('\s*\(teilweise\)')
    re14 = Regexp.new('([^)]*)\s*(\(E. [IVX]+, [0-9]+, [-0-9]+\))(.*)')
    re15 = Regexp.new('[^(]*\((E.[^)]*)')


    bildString = self[:photo]
    klammern = false
    stern = false


    while bildString.size > 0


      name = ''
      typ = '---'


      if self[:uid] == 9562
        if bildString.match('VIII')
          m15 = re15.match(bildString)
          kommentar = m15[1]
        else
          kommentar = ''
        end
      end

      if  re6.match(bildString)

        logger.info "\t[INFO]  [FL] match re6"

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

        m14 = re14.match(bildString)

        if m14 and self[:uid] < 9000
          # 6344-6356
          bildString = m14[1] + m14[3]
          kommentar = m14[2]

        elsif self[:uid] == 9834
          bildString = '3911 )*'
          kommentar = 'E. VIII, 108, nach 3'

        elsif self[:uid] == 9951
          bildString = '2374, 2375, 2376 )*'
          kommentar = 'E VIII, 122, 5 - 124, 18'

        elsif self[:uid] == 9562 and bildString.match('VIII')
          # hinter schließenden klammer weiter
          bildString = bildString[(bildString.index(')') + 1)..-1]
          klammern = false

        elsif self[:uid] == 9671
          kommentar = 'E. VIII, 87, 5'
          bildString = '141, 142, E. XIV, pl. DCLXIX, DCLXX )*'

        elsif self[:uid] == 9870
          kommentar = 'E. VIII, 111, 16'
          bildString = '114, 115, 116, 117)*'

        end

      elsif re8.match(bildString)
        # Klammer zu
        klammern = false
        bildString = bildString[((re8.match(bildString)[0]).length)..-1]

      elsif re1.match(bildString)
        # Fall 1: Dateiname nur aus Ziffern
        name = re1.match(bildString)[0]
        typ = 'alt'
        bildString = bildString[(name.length)..-1]

      elsif re2.match(bildString)
        # Fall 2: Dateiname der Form D03_XXXXX
        name = re2.match(bildString)[0]
        typ = 'D03'
        bildString = bildString[(name.length)..-1]

      elsif re3.match(bildString)
        # Fall 3: Dateiname der Form D05_XXXXX
        name = re3.match(bildString)[0]
        typ = 'D05'
        bildString = bildString[(name.length)..-1]

      elsif re4.match(bildString)
        # Fall 4: Dateiname der Form eXXX
        name = re4.match(bildString)[0]
        typ = 'e'
        bildString = bildString[(name.length)..-1]

      elsif re9.match(bildString)
        # Fall 5: Name der Form GXXX [ff.]
        name = re9.match(bildString)[1]
        typ = 'G'
        kommentar = re9.match(bildString)[2]
        bildString = bildString[((re9.match(bildString)[0]).length)..-1]

      elsif re10.match(bildString)
        # Fall 6: Name der Form e-onr-XXX
        name = re10.match(bildString)[0]
        typ = 'e-o'
        bildString = bildString[(name.length)..-1]

      elsif re11.match(bildString)
        # Fall 7: Labrique, Stylistique
        name = re11.match(bildString)[1]
        typ = 'Labrique, Stylistique'
        bildString = bildString[((re11.match(bildString)[0]).length)..-1]

      elsif re5.match(bildString)
        # Fall (n+1): Verweis auf Tafeln im Edfou Buch
        m = re5.match(bildString)
        typ = m[1]
        name = m[2]
        # rest = m.group(3)

        # kombi aus strip & führendes/endende Komma abschneiden
        bildString = bildString[((m[0]).length)..-1].match(/(^\s*,\s*)(.*)(\s*,\s*$)/)[2]

        if re7.match(bildString)
          # Es kommt noch ein Edfou Bild
          bildString = typ + ', pl. ' + bildString
        end
      else
        logger.warn "\t[WARN]  [FL] uid: #{self[:uid]} unklarer String:  #{:bildString}"
        bildString = ''
      end

      if (name.length) > 0

        if re12.match(bildString)
          # ist gefolgt von *
          stern = true
          bildString = bildString[((re12.match(bildString))[0]).length..-1]
        end

        if re13.match(bildString)
          kommentar = 'teilweise'
          bildString = bildString[(re13.match(bildString)[0]).length..-1]
        end

        if self[:uid] == 9910 and bildString.match('103')
          kommentar = 'E. VIII, 118, 7'
          bildString = ''
        end

        photoID = typ + '-' + name
        myPhoto = {}

        if photosDict.has_key?(photoID)
          myPhoto = photosDict[photoID]
          myPhoto['count'] += 1
        else
          if typ == 'D05' or typ == 'D03' or typ == 'alt'
            pfad = typ + '/' + name + '.jpg'
          else
            pfad = ''
          end

          myPhoto = {
              'uid' => photosDict.length,
              'photo_typ_uid' => photoTypDict[typ]['uid'],
              'name' => name,
              'count' => 1
          }
          photosDict[photoID] = myPhoto

        end

        # todo nur für Normalisierung?
        #collection['items'] += [photoID]
        #collection['klammern'] = klammern
        #collection['stern'] = stern
        #collection['kommentar'] = kommentar


        key = self[:uid].to_s + '-' + myPhoto['uid'].to_s

        # todo Relation formular_has_photoDict entfernt
        # if not formular_has_photoDict.has_key?(key)
        #   formular_has_photoDict[key] = {
        #       'uid_local' => self[:uid],
        #       'uid_foreign' => myPhoto['uid'],
        #       'kommentar' => kommentar
        #   }
        # end

      end


      puts bildString
      # kombi aus strip & führendes/endende Komma abschneiden
      m = bildString.match(/(^\s*,\s*)(.*)(\s*,\s*$)/)
      if m
        bildString = m[2]
      else
        # todo wirklich - testen
        bildString = ''
      end

      logger.info "\t[INFO]  [FL] while ende, bildString: #{bildString}  bildString.length=#{bildString.length} "

    end

    puts self[:photo]

    # todo: finishCollection(PRIMARY) nicht impl., wirklich benötigt? scheinbar nur für Normalisierung
    # finishCollection(PRIMARY)

  end

  def check_textposition_re_6

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
    band = []
    stelle = []


    # Felder
    @myFormular['texttyp'] = self[:texttyp]

    # Textposition

    # todo Konversion absichern Integer("1")

    myStelle = {}
    # todo entfernen? Gehört zur Normalisierung
    myStelle['band_uid'] = bandDict[Integer(self[:band])]['nummer']

    ## Sonderfälle
    szOriginal = self[:seitezeile]
    if self[:uid] == 3416
      self[:seitezeile] = "011, 09 - 012, 01"
    end
    if self[:uid] == 9583
      self[:seitezeile] = "078, 14 / Kol. 1"
    end
    if self[:uid] == 9584
      self[:seitezeile]= "078, 14 / Kol. 2"
    end

    kommentar = []

    if self[:seitezeile].index('nach ') == 0
      kommentar += ['nach']
      self[:seitezeile] = self[:seitezeile].gsub('nach ', '')
    end
    if self[:seitezeile].match(', Z')
      kommentar += [self[:seitezeile][self[:seitezeile].index(', Z') + 2..-1]]
      self[:seitezeile] = self[:seitezeile][self[:seitezeile].index(', Z')]
    end
    if self[:seitezeile].match(' / Z')
      kommentar += [self[:seitezeile][self[:seitezeile].index(' / Z') + 3..-1]]
     self[:seitezeile] = self[:seitezeile][self[:seitezeile].index(' / Z')]
    end
    if self[:seitezeile].match(', Kol')
      kommentar += [self[:seitezeile][self[:seitezeile].index(', Kol') + 2..-1]]
      self[:seitezeile]= self[:seitezeile][self[:seitezeile].index(', Kol')]
    end
    if self[:seitezeile].match(' / kol')
      kommentar += [self[:seitezeile][self[:seitezeile].index(' / kol') + 3..-1]]
      self[:seitezeile]= self[:seitezeile][self[:seitezeile].index(' / kol')]
    end
    if self[:seitezeile].match(' / ')
      kommentar += [self[:seitezeile][self[:seitezeile].index(' / ') + 3..-1]]
      self[:seitezeile]= self[:seitezeile][self[:seitezeile].index(' / ')]
    end

    if szOriginal != self[:seitezeile]
      logger.info "\t[INFO]  [FL] uid: #{self[:uid]} Aenderung SEITEZEILE, Original: #{szOriginal} neu: #{self[:seitezeile]}"
    end
    if (kommentar.length) > 0
      logger.info "\t[INFO]  [FL] uid: #{self[:uid]} SEITEZEILE + Kommentar: #{kommentar}"
    end
    if (self[:seitezeile].scan(/[^0-9, -]/)).length > 0
      logger.error "\t[ERROR]  [FL] uid: #{self[:uid]} Fehler mit SEITEZEILE,  #{self[:seitezeile]}"
    end

    myStelle['anmerkung'] = "; #{kommentar}"

    result = []
    if self[:seitezeile].match(' - ')
      # Form »002, 06 - 003, 02«
      szParts = self[:seitezeile].split(' - ')
      result << szSplit(szParts[0])
      result << szSplit(szParts[1])
    elsif self[:seitezeile].match(',')
      parts = self[:seitezeile].split(',')
      seite = parts[0]
      if parts[1].match('-')
        zeilen = parts[1].split('-')   # match(/(^\s*,\s*)(.*)(\s*,\s*$)/)[2]
        result = [[seite, Integer(zeilen[0].to_i)], [seite, Integer(zeilen[1].to_i)]]
      else
        zeile = Integer(parts[1])
        result = [[seite, zeile], [seite, zeile]]
      end
    else
      result = [[0, 0], [0, 0]]
      logger.error "\t[ERROR]  [FL] uid: #{self[:uid]} Fehler mit SEITEZEILE,  #{self[:seitezeile]}"
    end

    if result[0][0] > result[1][0]
      logger.error "\t[ERROR]  [FL] uid: #{self[:uid]} Fehler , SEITEN absteigend,  #{self[:seitezeile]}"
    end

    if result[0][0] == result[1][0] and result[0][1] > result[1][1]
      logger.error "\t[ERROR]  [FL] uid: #{self[:uid]} Fehler, ZEILEN absteigend,  #{self[:seitezeile]}"
    end

    myStelle['seite_start'] = result[0][0]
    myStelle['zeile_start'] = result[0][1]
    myStelle['seite_stop'] = result[1][0]
    myStelle['zeile_stop'] = result[1][1]

    if myStelle['zeile_start'] > 30
      logger.error "\t[ERROR]  [FL] uid: #{self[:uid]} Fehler, zeile_start > 30,  #{self[:seitezeile]}"
    end

    if myStelle['zeile_stop'] > 30
      logger.error "\t[ERROR]  [FL] uid: #{self[:uid]} Fehler, zeile_stop > 30,  #{self[:seitezeile]}"
    end

    myStelle['stop_unsicher'] = false
    myStelle['zerstoerung'] = false

    # todo Teil der Normalisierung ?
    myStelle['uid'] = stelle.length
    @myFormular['stelle_uid'] = stelle.length

    stelle << [myStelle]
    @formularDict[@myFormular['uid']] = @myFormular

  end

  # todo in module auslagern
  def szSplit(s)
    parts = s.gsub(' ', '').split(',')

    begin
      parts = [Integer(parts[0]), Integer(parts[1])]
    rescue ArgumentError
      logger.error "\t[ERROR]  [FL] Fehler bei der Auftrennung von: #{s} aufgelöst nach: #{parts}"
end

    return parts
  end

end





