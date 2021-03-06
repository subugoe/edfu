# encoding: utf-8

module VerifyWortHelper
  include EdfuDataMappings

  private

  def manipulate_and_create_belegstellen_and_stelle(belegstellenEdfu, belegstellenWb, uid, wort)

    stellen = Array.new

    re20         = Regexp.new(/^\s*([VI]*)\s*,?\s*(<?)([0-9]*)\s*,\s*([0-9\/ -]*)(>?\*?)\s*(.*)$/)

    #--- edfu


    @wbAnmerkung = ''


    edfuStopUnsicher = false
    edfuPlusFolgende = false

    wbStopUnsicher = false
    wbPlusFolgende = false


    bEdfu = belegstellenEdfu


    # 2132, 2276, 2325
    bEdfu = bEdfu.gsub(/E VII/, 'VII')

    # 3189, 3239
    #bEdfu = bEdfu.gsub(' f.', '')

    # 3514
    bEdfu = bEdfu.gsub('; ;', ';')


    if bEdfu.index('zum Beispiel') == 0
      # 1266, 1296, 2781, 2811
      bEdfu = bEdfu.gsub(/zum Beispiel/, '')
      addToEdfuStelleAnmerkung('(Beispiele)')

    elsif bEdfu == 'VIII, 026, 4; 033 16 '
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


    if match = bEdfu.match(/(^EPON; )(.*)(EPON; $)/)
      bEdfu = match[2]
    end

    # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
    bEdfu = bEdfu.gsub(/ \/ V/, '; V')


    if bEdfu != belegstellenEdfu
      Edfulog.new("ERROR", "WL", "Änderung an Belegstelle", "Belegstelle", belegstellenEdfu, bEdfu, uid)
    end


    #-- wb_berlin


    wb          = belegstellenWb
    wbID        = nil
    wbAnmerkung = nil
    notiz       = nil

    if wb == 'nicht im Wb belegt'
      wbID = 0
    elsif wb.length > 0
      if wb == 'nach II, 123, 12 - 124*'
        addToWbStelleAnmerkung(wb)
        wb = 'nach II, 123, 12 - 124, 1'

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
      # e.g. I, 046 - 047, 03
      m = wb.match(/([VI]*),([ 0-9,]*) ([0-9]*) - ([0-9]*). ([0-9]*)/)
      if m
        if m[2] == ''
          addToWbStelleAnmerkung(wb)
          wb = "#{m[1]}, #{m[3]}, #{m[5]} - #{m[4]}, #{m[5]}"
        end
      end

      if wb != belegstellenWb
        Edfulog.new("INFO", "WL", "Änderung an Belegstellen", "BelegstellenWb", belegstellenWb, wb, uid)
      end

      if wb.match(/ff/)
        wbStopUnsicher= true
        addToWbStelleAnmerkung(wb)
      elsif wb.match(/f/)
        wbPlusFolgende = true
        addToWbStelleAnmerkung(wb)
      end

      # vornach =  1 'nach '
      # vornach = -1 'vor '
      vornach = 0
      if wb.index('nach ') == 0
        vornach = 1
        addToWbStelleAnmerkung(wb)
        wb = wb.gsub(/nach /, '')
      elsif wb.index('vor ') == 0
        vornach = -1
        addToWbStelleAnmerkung(wb)
        wb = wb.gsub(/vor /, '')
      end

      wbBand_roemisch = wb[0 .. wb.index(',')-1]

      wb = wb[wb.index(',') + 1 .. -1].strip()
    end

    wbBand = roemisch_nach_dezimal(wbBand_roemisch)


    wb = wb.gsub(' -', '-').gsub('- ', '-')
    if wb.index('-') != nil
      # Range
      wbTeile = wb.split('-')
      if wbTeile.length == 2
        wbSeiteZeile = wbTeile[0].split(',')
        wbSeiteStart = (wbSeiteZeile[0].strip()).to_i
        wbSeiteStop  = wbSeiteStart


        begin
          if wbSeiteZeile[1] != nil and wbSeiteZeile[1].strip() != ''
            wbZeileStart = (wbSeiteZeile[1].strip()).to_i # if wbSeiteZeile[1] != nil
          else
            wbZeileStart = 1

            Edfulog.new("ERROR", "WL", "Zeilenstart auf 1 gesetzt", "BelegstellenWb", wb, '', uid)
          end
        rescue ArgumentError

          Edfulog.new("ERROR", "WL", "Datensatz fehlerhaft", "BelegstellenWb", wb, '', uid)
        end

        if wbTeile[1].index(',') != nil

          # Komma im zweiten Teil: unterschiedliche Seiten
          wbSeiteZeile2 = wbTeile[1].split(',')
          wbSeiteStop   = (wbSeiteZeile2[0].strip()).to_i
          wbZeileStop   = (wbSeiteZeile2[1].strip()).to_i
        else
          # Range innerhalb einer Seite
          if wbPlusFolgende
            wbZeileStop = (wbTeile[1].strip()).to_i + 1
          else
            wbZeileStop = (wbTeile[1].strip()).to_i
          end

        end

        wbStart = [wbSeiteStart, wbZeileStart]
        wbStop  = [wbSeiteStop, wbZeileStop]

      else
        Edfulog.new("ERROR", "WL", "Formatfehler bei Belegtstelle", "BelegstellenWb", wb, '', uid)
      end

    else

      # Nur eine Stelle
      begin
        wbStart = szSplit(wb)
      rescue ArgumentError
        Edfulog.new("ERROR", "WL", "Belegstelle konnte nicht gesplittet werden", "BelegstellenWb", wb, '', uid)
        wbStart = [0, 0]
      end

      if wbPlusFolgende
        wbStop = [wbStart[0], wbStart[1] + 1]
      else
        wbStop = wbStart
      end
    end


    dbWB             = Wbberlin.new
    dbWB.band        = wbBand || 'unbekannt'
    dbWB.seite_start = wbStart[0] || ''
    dbWB.seite_stop  = wbStop[0] || ''
    dbWB.zeile_start = wbStart[1] || ''
    dbWB.zeile_stop  = wbStop[1] || ''
    dbWB.notiz       = @wbAnmerkung
    #dbWB.wort        = wort
    dbWB.id          = ActiveRecord::Base.connection.execute("select nextval('wbsberlin_id_seq')").first['nextval']

    wort.wbberlin  = dbWB


    #--- edfu


    band           = ''
    edfuSeiteStart = 0
    zerstoerung    = false
    bandRoemisch   = ''
    bandDezimal    = 0

    if bEdfu.length > 0
      belegstellen = bEdfu.strip.split(';')
      a            = belegstellen.size
      belegstellen.each { |b|

        @edfuAnmerkung = ''
        b              = b.strip()

        if b.match(/ff/)
          edfuStopUnsicher = true
          addToEdfuStelleAnmerkung(b)
        elsif b.match(/f/)
          edfuPlusFolgende = true
          addToEdfuStelleAnmerkung(b)
        end


        klammer = false
        stern   = false
        # todo: is there any STELLE with "%"
        if b.index('%') != nil
          zerstoerung = true
          b           = b.gsub('%', '').gsub('&', '')

        end

        # todo: check this
        if b.index(',') == nil
          if edfuSeiteStart != 0
            b = edfuSeiteStart.to_s + ', ' + b

          else
            Edfulog.new("ERROR", "WL", "Keine Seitenzahl vorhanden", "BelegstellenEdfu", bEdfu, '', uid)
          end

        end

        m20 = re20.match(b)

        if m20

          if (m20[1]).length > 0
            bandRoemisch = m20[1].strip()
            bandDezimal  = roemisch_nach_dezimal bandRoemisch
          elsif bandDezimal == 0
            Edfulog.new("ERROR", "WL", "Fehlende Bandangabe", "BelegstellenEdfu", bEdfu, '', uid)
          end

          edfuSeiteStart = m20[3].to_i
          edfuSeiteStop  = edfuSeiteStart

          if m20[4].index(' - ') != nil
            edfuZeileStart = (m20[4].split(' - ')[0]).to_i
            edfuZeileStop  = (m20[4].split(' - ')[1]).to_i
          else
            zeilenString = m20[4]
            zeilenString = zeilenString.gsub('/', '-').gsub(' ', '')
            zeilen       = zeilenString.split('-')

            if zeilen.length == 1
              edfuZeileStart = zeilen[0].to_i
              if edfuPlusFolgende
                edfuZeileStop = edfuZeileStart+1
              else
                edfuZeileStop = edfuZeileStart
              end


            elsif zeilen.length == 2
              edfuZeileStart = (zeilen[0]).to_i
              edfuZeileStop  = (zeilen[1]).to_i
            else
              Edfulog.new("ERROR", "WL", "Zu viele Komponenten", "BelegstellenEdfu", bEdfu, '', uid)
            end
          end


          # todo: Stern (chassinat_verbessert) und Klammer (schreiber_verbessert)
          if m20[5] == ">"
            addToEdfuStelleAnmerkung(b)
            klammer = true
          elsif m20[5] == ">*"
            addToEdfuStelleAnmerkung(b)
            stern = true
          elsif (m20[5]).length > 2
            Edfulog.new("ERROR", "WL", "Bandangabe zu lang (#{b})", "BelegstellenEdfu", bEdfu, '', uid)
          end


          stelle = Stelle.fetch(
              "wort",
              'Edfu',
              bandDezimal,
              "#{bandRoemisch}, #{'%03i' % (edfuSeiteStart)}",
              "#{bandRoemisch}, #{'%03i' % (edfuSeiteStart)}, #{'%02i' % (edfuZeileStart)}",
              edfuSeiteStart,
              edfuSeiteStop,
              edfuZeileStart,
              edfuZeileStop,
              @edfuAnmerkung,
              edfuStopUnsicher,
              false,
              banddict((bandDezimal).to_i, 'freigegeben')
          )

          stellen << stelle unless stellen.include? stelle

          if edfuZeileStart == nil
            Edfulog.new("ERROR", "WL", "Startzeile ungültig", "BelegstellenEdfu", bEdfu, '', uid)
          elsif edfuZeileStart > 30
            Edfulog.new("ERROR", "WL", "Startzeile > 30 (#{edfuZeileStart})", "BelegstellenEdfu", bEdfu, '', uid)
          end

          if edfuZeileStop == nil
            Edfulog.new("ERROR", "WL", "Stopzeile ungültig", "BelegstellenEdfu", bEdfu, '', uid)
          elsif edfuZeileStop > 30
            Edfulog.new("ERROR", "WL", "Stopzeile > 30 (#{edfuZeileStop})", "BelegstellenEdfu", bEdfu, '', uid)
          end


        else

          Edfulog.new("ERROR", "WL", "Belegstelle (#{b}) verworfen", "BelegstellenEdfu", bEdfu, '', uid)
        end

        # todo: check this
        # bildString = bildString.strip.sub(/^[,.:\s]*/, '').strip # m[2]

      }

    end


    return stellen
  end

  def szSplit(s)
    parts = s.gsub(' ', '').split(',')
    parts = [(parts[0]).to_i, (parts[1]).to_i]

    return parts
  end

  def addToEdfuStelleAnmerkung(str)
    @edfuAnmerkung = str
  end

  def addToWbStelleAnmerkung(str)
    @wbAnmerkung = str
  end

end
