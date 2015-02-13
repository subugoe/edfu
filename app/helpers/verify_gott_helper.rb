# encoding: utf-8

require 'edfu_numerics_conversion_helper'
require 'stellen_helper'

module VerifyGottHelper
  include EdfuNumericsConversionHelper # , Celluloid


  private
  def manipulate_seitezeile_string_and_create_stelle(seitezeile, uid, band)


    stellen = Array.new

    re3 = Regexp.new(/^\s*([VI]*)\s*,*\s*([0-9]*)\s*,\s*([0-9\/ -]*)\s*(.*)$/)


    originalSEITEZEILE = seitezeile
    stelleAnmerkung    = ''

    if seitezeile == '066, 011ff,;'
      # 84
      seitezeile = '066, 011ff'
    elsif seitezeile == '264-269;'
      # 1551
      seitezeile = '264, 0 - 269, 30;'
    elsif seitezeile == '2,7?'
      # 1178
      seitezeile      = '2, 7'
      stelleAnmerkung = '2,7?'
    elsif seitezeile == '052, 006 und 008;'
      # 2376
      seitezeile = '052, 6-8'
    elsif seitezeile == '215, 11 (2x)-216, 1 (1'
      # 2463
      seitezeile = '215, 11 - 216, 1'
    elsif seitezeile == '159'
      # 3266
      seitezeile = '159, 0'
    elsif seitezeile == '149, 3:'
      # 3654
      seitezeile = '149, 3'
    elsif seitezeile == '90, 3 (25);'
      # 4093
      seitezeile      = '90, 3;'
      stelleAnmerkung = '(25)'
    elsif seitezeile == '39, 11/f.'
      # 5487
      seitezeile = '39, 11f.'
    elsif seitezeile == '90,3 (36)'
      # 5758
      seitezeile      = '90,3'
      stelleAnmerkung = '(36)'
    elsif seitezeile == '33,14 33,14'
      # 5791
      seitezeile = '33, 14'
    elsif uid == 6335
      band = 'VII' # 7'
    elsif seitezeile == '331,6 und 332,1'
      # 6420
      seitezeile = '331, 6 - 332, 1'
    elsif seitezeile == '331,9 und 332,5'
      # 6421
      seitezeile = '331, 9 - 332, 5'
    elsif seitezeile == '114,4 114,7                                                114,4'
      # 7603
      seitezeile = '114, 4-7'
    elsif seitezeile == '47,5 47,5- 47,5'
      # 7616
      seitezeile = '47, 5'
    elsif seitezeile == '24;4'
      # 7693
      seitezeile = '24, 4'
    elsif seitezeile == '75,13 75,13 75,13'
      # 7875
      seitezeile = '75, 13'
    elsif seitezeile == '54;3'
      # 8222
      seitezeile = '54, 3'
    elsif seitezeile == '137, 008-138'
      # 8337
      seitezeile = '137, 008 - 138, 10'
    elsif seitezeile == '201; 008'
      # 8853
      seitezeile = '201, 008'
    elsif seitezeile == '067; 004'
      # 8918
      seitezeile = '067, 004'
    elsif seitezeile == '018; 009'
      # 8939
      seitezeile = '018, 009'
    elsif uid == 9165
      band = 'V' # '5'
    elsif uid == 7740
      band = 'VII' # 'VIi'
    end


    # if seitezeile.class == Float
    #   seitezeile = seitezeile.to_s
    # end
    #
    # if originalSEITEZEILE.class == Float
    #   originalSEITEZEILE = originalSEITEZEILE.to_s
    # end


    szsz         = seitezeile.gsub(' ', '')
    halbeLaenge  = (szsz.length / 2).to_i
    halberString = szsz[halbeLaenge..-1]
    if (halberString + halberString) == szsz
      seitezeile = halberString
    end

    seitezeile = seitezeile.gsub('.09999999999999', ', 1')
    seitezeile = seitezeile.gsub('.300000000000001', ', 3')
    seitezeile = seitezeile.gsub('.30000000000001', ', 3')
    seitezeile = seitezeile.gsub('.40000000000001', ', 4')
    seitezeile = seitezeile.gsub('.59999999999999', ', 6')
    seitezeile = seitezeile.gsub('.699999999999999', ', 7')
    seitezeile = seitezeile.gsub('.69999999999999', ', 7')
    seitezeile = seitezeile.gsub('.90000000000001', ', 9')
    seitezeile = seitezeile.gsub('.109999999999999', ', 11')
    seitezeile = seitezeile.gsub('.119999999999999', ', 12')
    seitezeile = seitezeile.gsub('.140000000000001', ', 14')
    seitezeile = seitezeile.gsub('.14000000000001', ', 14')
    seitezeile = seitezeile.gsub('.15000000000001', ', 15')
    seitezeile = seitezeile.gsub('.18000000000001', ', 18')


    if match = seitezeile.match(/([0-9]+)\.([0-9]+)/)
      seitezeile = seitezeile.gsub(/([0-9]+)\.([0-9]+)/, "#{match[1]}, #{match[2]}") # (..), (..)
    end

    seitezeile = seitezeile.gsub(/und/, ';')

    if originalSEITEZEILE != seitezeile

      str = ''
      if seitezeile == originalSEITEZEILE.strip
        str = "Änderung an Seitezeile (leerzeichan am Anfang oder Ende entfernt)"
      else
        str = "Änderung an Seitezeile"
      end


      Edfulog.new("ERROR", "GL", str, "SEITEZEILE", originalSEITEZEILE, seitezeile, uid)
    end


    teile = seitezeile.split(";")

    teile.each { |sz|


      # todo check the following

      # if match = seitezeile.match(/(^\s*;*\s*)([0-9 ,]*)(\s*;*\s*$)/) #(/(^\s*;\s*)(.*)(\s*;\s*$)/)


      #szs = match[2].split(';')
      #if szs.length == 1 and szs[0].length > 1
      #sz = szs[0]


      stopUnsicher = false
      #if match = sz.match(/(^\s*,*\s*)([0-9 ,]*)(\s*,*\s*$)/)
      #sz          = match[2]
      komponenten  = sz.split(',')
      if komponenten.length == 1
        # nur eine Komponente: nur eine Seitenzahl vorhanden, mit Zeile 0 ergänzen
        match = sz.match(/([0-9]*)(.*)/)

        sz          = sz.gsub('([0-9]*)(.*)', "#{match[1]},0#{match[2]}")
        komponenten = sz.split(',')
      end

      if komponenten.length > 2
        sz = sz.gsub(' ', '')
        sz = sz.gsub('/', '-')
        sy = sz.split('-')
        if sy.length == 2
          start      = szSplit(sy[0])
          stop       = szSplit(sy[1])
          startSeite = start[0]
          startZeile = start[1]
          stopSeite  = stop[0]
          stopZeile  = stop[1]
        else
          Edfulog.new("ERROR", "GL", "Fehlerhafte Komponentenzahl", "SEITEZEILE", sz, '', uid)
        end

      else
        startSeite = (komponenten[0]).to_i
        stopSeite  = startSeite

        if komponenten.size == 2
          zeilen = komponenten[1].strip()
          if zeilen.match(/f/)

            stopUnsicher = true   # todo: ff. steht eigentlich für folgende zeilen, hier aber stop unsicher !!!
            # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
            zeilen       = zeilen.gsub(/\s*f+\.*/, '')
          end

          # eigentlich sub, beim testen hat sub in python aber nicht nur das erste Vorkommen ersetz
          zeilen = zeilen.gsub(/[ \/-]+/, '-')
          zs     = zeilen.split('-')

          startZeile = (zs[0]).to_i
          if zs.length > 1

            stopZeile = (zs[1]).to_i
          else
            stopZeile = startZeile
          end
        end
      end


      startZeile ||= 1
      stopZeile  ||= 30

      dezimal_band = roemisch_nach_dezimal(band.to_s.strip).to_i


      if startSeite > 0 and dezimal_band > 0


        stelle_obj = Stelle.fetch(
            "gott",
            'Edfu',
            dezimal_band,
            "#{band}, #{'%03i' % (startSeite)}",
            "#{band}, #{'%03i' % (startSeite)}, #{'%02i' % (startZeile)}",
            startSeite,
            stopSeite,
            startZeile,
            stopZeile,
            stelleAnmerkung,
            stopUnsicher,
            false,
            StellenHelper.getFromBanddict((dezimal_band).to_i, 'freigegeben')
        )

        if stelle_obj.class == Array
          stelle_obj = stelle_obj[0]
        end

        stellen << stelle_obj unless stellen.include? stelle_obj

        if startZeile > 30
          Edfulog.new("ERROR", "GL", "Startzeile > 30", "SEITEZEILE", originalSEITEZEILE, '', uid)
        end


        if stopZeile > 30
          Edfulog.new("ERROR", "GL", "Stopzeile > 30", "SEITEZEILE", originalSEITEZEILE, '', uid)
        end


      else
        Edfulog.new("ERROR", "GL", "Startseite oder Band nicht ermittelbar", "SEITEZEILE", originalSEITEZEILE, '', uid)
      end

    }

    return stellen

  end


end
