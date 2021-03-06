# encoding: utf-8

module VerifyOrtHelper
  include EdfuDataMappings

  private

  def manipulate_stelle_string_and_create(stelle, uid, ort)

    re3 = Regexp.new(/^\s*([VI]*)\s*,*\s*([0-9]*)\s*,\s*([0-9\/ -]*)\s*(.*)$/)

    originalStelle = stelle


    if stelle == 'VIII, 73, 5; 73, 7 (sic; statt   lies wohl  , gegen Anm. 6);'
      # 240
      stelle = 'VIII, 73, 5; 73, 7 (sic - statt   lies wohl  , gegen Anm. 6)'
    elsif stelle == 'VIII, 42, 9; 42, 15; 77, 1; 125, 10; 126, 13; 133, 16; VII, [54, 16]; 88, 1; 184, 15; 191, 14; VI, 229, 1;'
      # 247
      stelle = 'VIII, 42, 9; 42, 15; 77, 1; 125, 10; 126, 13; 133, 16; VII, 54, 16 []; 88, 1; 184, 15; 191, 14; VI, 229, 1;'
    elsif stelle == 'V, 8, 10; 10, 5; 31, 5; 33, 12; 35, 3; 46, 1; 98, 13; 100, 7; 127, 2; 128, 2; 158, 1; 168, 1; 170, 3 ( ); 173, 12; 205, 6; 220, 6; 222, 17; 226, 7; 278, 14; 284, 10; 304, 7; 305, 2; 337, 1; 343, 1; 346, 2 (3x); 3 (2x); 4 (2x); 5 (2x); 6 (3x); 347, 1 (2x); 4; 357, 6; 359, 2; 383, 4; 394, 14;'
      # 356
      stelle = 'V, 8, 10; 10, 5; 31, 5; 33, 12; 35, 3; 46, 1; 98, 13; 100, 7; 127, 2; 128, 2; 158, 1; 168, 1; 170, 3 ( ); 173, 12; 205, 6; 220, 6; 222, 17; 226, 7; 278, 14; 284, 10; 304, 7; 305, 2; 337, 1; 343, 1; 346, 2 (3x); 346, 3 (2x); 346, 4 (2x); 346, 5 (2x); 346, 6 (3x); 347, 1 (2x); 347, 4; 357, 6; 359, 2; 383, 4; 394, 14'
    elsif stelle == 'VIII, 169, 1 (Tempel!); VII, 2, 7; 10, 6; 20, 2 (als Gebieterin u. Herrin der Städte; wohl der Tempel); 20, 10; 20, 14; 22, 6; 23, 10; 25, 1 (die Gebieterin der Städte und Gaue); 25, 11; 39, 7; 40, 13; 52, 7; 60, 11; 61, 10;'
      # 504
      stelle = 'VIII, 169, 1 (Tempel!); VII, 2, 7; 10, 6; 20, 2 (als Gebieterin u. Herrin der Städte - wohl der Tempel); 20, 10; 20, 14; 22, 6; 23, 10; 25, 1 (die Gebieterin der Städte und Gaue); 25, 11; 39, 7; 40, 13; 52, 7; 60, 11; 61, 10'
    elsif stelle == 'VI, 209 4 (Gau); 209, 5 (Stadt); 216, 9; 217, 2; 224, 11; 237, 6; 242, 16; 243, 6; 244, 4; 245, 5; 247, 5; 249, 13; 261, 11; 263, 10; 270, 2; 273, 8; 273, 10; 276, 11; 278, 16; 282, 8; 282, 11; 283, 7; 283, 13; 284, 15; 285, 11; 288, 4; 288, 7; 290, 4; 291, 5;'
      # 509
      stelle = 'VI, 209, 4 (Gau); 209, 5 (Stadt); 216, 9; 217, 2; 224, 11; 237, 6; 242, 16; 243, 6; 244, 4; 245, 5; 247, 5; 249, 13; 261, 11; 263, 10; 270, 2; 273, 8; 273, 10; 276, 11; 278, 16; 282, 8; 282, 11; 283, 7; 283, 13; 284, 15; 285, 11; 288, 4; 288, 7; 290, 4; 291, 5;'
      # in Tabelle geändert
      # elsif uid == 579
      #   anm    = stelle
      #   stelle = ''
    elsif stelle == 'VI, 68, 3; 237, 9; 277, 6; 310, 13; V, 9, 2 ([]; wohl Ägypten); 24, 8 (Ägypten: "das Versiegelte"); 44, 4 (Welt); 59, 5; 63, 1; 64, 7; 70, 3; 80, 6 (Welt); 84, 8 (Welt); 92, 1; 101, 13; 157, 12 (Welt);'
      # 619
      stelle= 'VI, 68, 3; 237, 9; 277, 6; 310, 13; V, 9, 2 ([], wohl Ägypten); 24, 8 (Ägypten: "das Versiegelte"); 44, 4 (Welt); 59, 5; 63, 1; 64, 7; 70, 3; 80, 6 (Welt); 84, 8 (Welt); 92, 1; 101, 13; 157, 12 (Welt);'
    elsif stelle == 'VIII, 5, 11; (vergleiche auch 8, 9; V, 95, 12 ([]); 324, 5;'
      # 628
      stelle= 'VIII, 5, 11 (vergleiche auch 8, 9); V, 95, 12 ([]); 324, 5'
    elsif stelle == 'VII, 326, 6; VI, 17, 1; 58, 16; 65, 2; 71, 11; 86, 8; 158, 12; 278, 12; 280, 6; 299, 6; 304, 6; 309, 6; 317, 2; 319, 15;V, 60, 7; 77, 5; 78, 13; 86, 10; 151, 4 ([];<>); 159, 13; 162, 3;'
      # 722
      stelle = 'VII, 326, 6; VI, 17, 1; 58, 16; 65, 2; 71, 11; 86, 8; 158, 12; 278, 12; 280, 6; 299, 6; 304, 6; 309, 6; 317, 2; 319, 15;V, 60, 7; 77, 5; 78, 13; 86, 10; 151, 4 ([],<>); 159, 13; 162, 3;'
    elsif stelle == 'VI, 36, 11; 208, Anm. 2; 328, 17/18;'
      # 751
      stelle = 'VI, 36, 11; 208, 0 (Anm. 2); 328, 17/18;'
    elsif stelle == 'VIII, 53, 1; 53, 2; 53, 5; 57, 8; 57, 11; 60, 14-61, 1; 61, 15; 66, 6; 71, 6; 71, 7; VII, 69, 4; 76, 15; 76, 15/16; 106, 13; 131, 2; 131, 6; 190, 1; 204, 7; 204, 10; 204, 15; 211, 6/7; 254, 3; 270, 14; 270, 16; 292, 4; 304, 12; 317, 7; 317, 13;'
      # 892
      stelle = 'VIII, 53, 1; 53, 2; 53, 5; 57, 8; 57, 11; 60, 14 - 61, 1; 61, 15; 66, 6; 71, 6; 71, 7; VII, 69, 4; 76, 15; 76, 15/16; 106, 13; 131, 2; 131, 6; 190, 1; 204, 7; 204, 10; 204, 15; 211, 6/7; 254, 3; 270, 14; 270, 16; 292, 4; 304, 12; 317, 7; 317, 13;'
    elsif stelle == 'VII, 2, 4; 3, 4; 5, 2; 7, 6; 8, 2; 8, 7; 9, 7; 10, 8; 13, 2; 15, 9; 21, 9; 22, 1; 22, 11; 22, 12 (2x); 24, 2; 26, 7; 26, 8; 31, 5; 35, 9; 36, 4; 40, 11; 43, 3; 44, 5; 61, 4; 74, 17; (Gau); 88, 4; 89, 8; 100, 16; 102, 1; 105, 10; 105, 14; 108, 2; 108, 3; 111, 11; 119, 6; 120, 6; 125, 10; 126, 3; 130, 12;'
      # 939
      stelle = 'VII, 2, 4; 3, 4; 5, 2; 7, 6; 8, 2; 8, 7; 9, 7; 10, 8; 13, 2; 15, 9; 21, 9; 22, 1; 22, 11; 22, 12 (2x); 24, 2; 26, 7; 26, 8; 31, 5; 35, 9; 36, 4; 40, 11; 43, 3; 44, 5; 61, 4; 74, 17 (Gau); 88, 4; 89, 8; 100, 16; 102, 1; 105, 10; 105, 14; 108, 2; 108, 3; 111, 11; 119, 6; 120, 6; 125, 10; 126, 3; 130, 12;'
    elsif stelle == 'V, 175, 18-176, 1;'
      # 993
      stelle= 'V, 175, 18 - 176, 1;'
    elsif stelle == 'V, 42, 9; 63, 9 ([]); 71, 13/14 ([]); 86, 7/8; 89, 15; 151, 17-152, 1; 155, 1; 162, 6; 165, 9; 206, 2; 215, 10; 231, 3/4; 244, 14; 288, 16/17; 300, 19; 326, 7; 396, 7;'
      # 1067
      stelle = 'V, 42, 9; 63, 9 ([]); 71, 13/14 ([]); 86, 7/8; 89, 15; 151, 17 - 152, 1; 155, 1; 162, 6; 165, 9; 206, 2; 215, 10; 231, 3/4; 244, 14; 288, 16/17; 300, 19; 326, 7; 396, 7;'
    elsif stelle == 'VI, 105, 5; 107, 3; 107, 8; 108, 12; 143, 3; 152, 1; 152, 16; 158, 1; 169, 174, 1; 174, 17; 175, 1; 179, 8; 181, 7; 186, 4; 190, 5; 199, 2; 237, 6; 237, 10; 243, 16; 244; 13; 245, 15; 248, 5; 249, 14; 260, 3; 274, 13; 276, 7; 276, 10; 277, 4/5; 277, 14/15;'
      # 1072
      stelle = 'VI, 105, 5; 107, 3; 107, 8; 108, 12; 143, 3; 152, 1; 152, 16; 158, 1; 169, 1; 174, 17; 175, 1; 179, 8; 181, 7; 186, 4; 190, 5; 199, 2; 237, 6; 237, 10; 243, 16; 244, 13; 245, 15; 248, 5; 249, 14; 260, 3; 274, 13; 276, 7; 276, 10; 277, 4/5; 277, 14/15;'
    elsif stelle == 'VI, 278, 9; 278, 17; 280, 15; 281, 15; 283, 9; 283, 11; 287, 3; 290, 11; 297, 17; 299, 3 ([]); 303, 16; 308, 10; 315; 7; 319, 14; 324, 4; 325, 7; 332, 1; 334, 4; 349, 6; 351, 14; V, 4, 1; 7, 1; 13, 12; 31, 5; 31, 6; 36, 2; 38, 11; 39, 10; 40, 4; 41, 2; 44, 11; 50, 12; 55, 1; 56, 11; 58, 15, 16;'
      # 1073
      stelle = 'VI, 278, 9; 278, 17; 280, 15; 281, 15; 283, 9; 283, 11; 287, 3; 290, 11; 297, 17; 299, 3 ([]); 303, 16; 308, 10; 315, 7; 319, 14; 324, 4; 325, 7; 332, 1; 334, 4; 349, 6; 351, 14; V, 4, 1; 7, 1; 13, 12; 31, 5; 31, 6; 36, 2; 38, 11; 39, 10; 40, 4; 41, 2; 44, 11; 50, 12; 55, 1; 56, 11; 58, 15, 16;'
    elsif stelle == 'VIII, <23, 2>;'
      # 1198
      stelle = 'VIII, 23, 2 (<23, 2>)'
    end

    if stelle != originalStelle
      Edfulog.new("ERROR", "OL", "Änderung an Stelle", "STELLE", originalStelle, stelle, uid)
    end


    # match als strip(char)-Ersatz
    teile = stelle.strip.split(';') #.match(/(^\s*;\s*)(.*)(\s*;\s*$)/))[2].split(';')


    myBand                  = ''
    bandNr                  = 0


    @ort_stelle_szene_batch = Array.new if @ort_stelle_szene_batch == nil

    teile.each do |teil|

      if (teil.strip()).length > 0

        m3 = re3.match(teil)

        if not m3
          Edfulog.new("ERROR", "OL", "Fehlerhafte Stelle", "STELLE", originalStelle, '', uid)
        else

          myBand = m3[1].strip() unless m3[1].empty?

          if (myBand).length > 0
            bandNr = roemisch_nach_dezimal(myBand)
          end


          seiteStart = (m3[2].strip()).to_i
          seiteStop  = seiteStart
          zeileStart = 100
          zeileStop  = 100

          if m3[3].index(' - ') != nil
            seiteStop = (m3[3].split(' - ')[1]).to_i

            zeileStart = (m3[3].split(' - ')[0]).to_i

            begin

              zeileStop = (m3[4].match(/(^[\s,]*)(\d*)([\s;]*$)/)[2]).to_i
            rescue NoMethodError
              Edfulog.new("ERROR", "OL", "Fehlerhafte Stelle", "STELLE", originalStelle, '', uid)
            end

            kommentar = ''
          else
            z          = m3[3].gsub(' ', '').gsub('/', '-')
            zeilen     = z.split('-')
            zeileStart = (zeilen[0]).to_i

            if zeilen.length == 1
              zeileStop = zeileStart
            else
              zeileStop = (zeilen[1]).to_i
            end

            kommentar = m3[4].strip()

          end

          stelle_obj = Stelle.fetch(
              "ort",
              'Edfu',
              bandNr,
              "#{myBand}, #{'%03i' % (seiteStart)}",
              "#{myBand}, #{'%03i' % (seiteStart)}, #{'%02i' % (zeileStart)}",
              seiteStart,
              seiteStop,
              zeileStart,
              zeileStop,
              kommentar, # todo: sind hier nur stellen anmerkungen drin?
              false,
              false,
              banddict(bandNr.to_i, 'freigegeben')
          )

          #---

          szenen     = Szene.szenen["#{bandNr}_#{seiteStart}"]


          if (szenen != nil && szenen.size > 0)

            szenen.each { |szene|

              stelle_obj.szenen << szene
              szene.stellen << stelle_obj

              # todo: required? ort.stellen...szenen
              ort.szenen = Array.new if ort.szenen == nil
              ort.szenen << szene


              stz = StellenSzenen.fetch(stelle_obj, szene)
              if stz.class == Array

                stz = stz[0]
                @ort_stelle_szene_batch << stz

              end
            }

          end

          #---

          # todo: hier steigt er aus !!! Array hat keine m. zugehoerigZU???
          stelle_obj.zugehoerigZu = ort
          ort.stellen << stelle_obj

          if zeileStart > 30
            Edfulog.new("ERROR", "OL", "Startzeile > 30", "STELLE", originalStelle, '', uid)
          end


          if zeileStop > 30
            Edfulog.new("ERROR", "OL", "Stopzeile > 30", "STELLE", originalStelle, '', uid)
          end


        end
      end
    end

    return @ort_stelle_szene_batch
  end
end
