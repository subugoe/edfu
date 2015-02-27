# encoding: utf-8

require 'roo'
require 'securerandom'
require 'benchmark'
require 'verify_formular_helper'
require 'verify_ort_helper'
require 'verify_gott_helper'
require 'verify_wort_helper'
require 'csv'
# require 'scrape'
require 'stellen_helper'


class UploadsController < ApplicationController
  include VerifyFormularHelper, VerifyOrtHelper, VerifyGottHelper, VerifyWortHelper, Celluloid

  before_action :set_upload, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!


  # todo add email for notification
  # todo add worker queue/thread for async processing

  SOLR_DOMAIN = ENV['EDFU_SOLR_1_PORT_8983_TCP_ADDR']
  SOLR_PORT   = ENV['SOLR_PORT_8983_TCP_PORT']

  # GET /uploads/new
  def new
    @upload = Upload.new
  end


  # POST /uploads
  # POST /uploads.json
  def create

    @upload = Upload.new(upload_params)


    @uploaded_formular = params[:upload][:formular]
    @uploaded_ort      = params[:upload][:ort]
    @uploaded_gott     = params[:upload][:gott]
    @uploaded_wort     = params[:upload][:wort]
    # @email             = params[:upload][:email]


    # logging format
    # betrifft,   text,       spalte, original, neu,  uid
    # [FL],       ändere...,  ...,    ...,      ...,  ...

    n                  = 50000

    # todo valdate tables (all columns?)

    File.open(Rails.root.join('public', 'uploads', @uploaded_formular.original_filename), 'wb') do |file|
      file.write(@uploaded_formular.read)
    end

    File.open(Rails.root.join('public', 'uploads', @uploaded_ort.original_filename), 'wb') do |file|
      file.write(@uploaded_ort.read)
    end

    File.open(Rails.root.join('public', 'uploads', @uploaded_gott.original_filename), 'wb') do |file|
      file.write(@uploaded_gott.read)
    end

    File.open(Rails.root.join('public', 'uploads', @uploaded_wort.original_filename), 'wb') do |file|
      file.write(@uploaded_wort.read)
    end


    self.async.process_files

    respond_to do |format|
      format.html { redirect_to uploads_path, notice: "File(s) staged." }
    end

  end


  # # DELETE /uploads/1
  # # DELETE /uploads/1.json
  # def destroy
  #   @upload.destroy
  #   respond_to do |format|
  #     format.html { redirect_to uploads_url, notice: 'Upload was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_upload
    @upload = Upload.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def upload_params
    #params.require(:upload).permit(:formular, :ort, :gott, :wort)
  end

  def process_files

    Benchmark.bm(7) do |x|
      x.report("processing:") {

        puts "deleteDB"
        deleteDB

        puts "process_szene"
        process_szene


        puts "process_formular"
        process_formular


        puts "process_ort"
        process_ort

        puts "process_gott"
        process_gott


        puts "process_wort"
        process_wort


        puts "save_Stellen"
        save_stellen

        puts "save_Szenen"
        save_szenen


        puts "cleanupSolr"
        cleanupSolr

        puts "updateSolr"
        updateSolr

      }
    end

  end

  def deleteDB


    # Rails.cache.clear

    Edfulog.delete_all
    Formular.delete_all
    FormulareLiteraturen.delete_all
    FormularePhotos.delete_all
    Gott.delete_all
    Literatur.delete_all
    Ort.delete_all
    Photo.delete_all
    Stelle.delete_all
    Wort.delete_all
    Wbberlin.delete_all
    Szene.delete_all
    StellenSzenen.delete_all


  end

  def cleanupSolr

    solr = RSolr.connect :url => "http://#{SOLR_DOMAIN}:#{SOLR_PORT}/solr/collection1"
    #solr = RSolr.connect :url => "http://localhost:8983/solr/collection1"
    solr.update :data => '<delete><query>*:*</query></delete>'
    solr.update :data => '<commit/>'

  end

  def updateSolr

    if (@word_solr_batch != nil && @word_solr_batch.size > 0)
      add_to_solr(@word_solr_batch)
    end

    if @gott_solr_batch != nil && @gott_solr_batch.size > 0
      add_to_solr(@gott_solr_batch)
    end

    if @ort_solr_batch != nil && @ort_solr_batch.size > 0
      add_to_solr(@ort_solr_batch)
    end

    if @formular_solr_batch != nil && @formular_solr_batch.size > 0
      add_to_solr(@formular_solr_batch)
    end

    if @szene_solr_batch != nil && @szene_solr_batch.size > 0
      add_to_solr(@szene_solr_batch)
    end

    if @stelle_solr_batch != nil && @stelle_solr_batch.size > 0
      add_to_solr(@stelle_solr_batch)
    end

  end


  def add_to_solr(solr_string_array)

    solr = RSolr.connect :url => "http://#{SOLR_DOMAIN}:#{SOLR_PORT}/solr/collection1"
    #solr = RSolr.connect :url => "http://localhost:8983/solr/collection1"
    solr.add (solr_string_array)
    solr.commit

  end


  def process_formular


    max_batch_size = 500
    n              = 50000
    i              = 0

    @formular_solr_batch = Array.new

    @formular_batch           = Array.new
    #@stelle_batch             = Array.new
    @photo_batch              = Array.new
    @literatur_batch          = Array.new
    @formular_photo_batch     = Array.new
    @formular_literatur_batch = Array.new
    @stelle_szene_batch       = Array.new if @stelle_szene_batch == nil

    # excel               = Roo::Excel.new("public/uploads/Formular.xls")
    excel                     = Roo::Excel.new("public/uploads/#{@uploaded_formular.original_filename}")
    excel.default_sheet       = excel.sheets.first

    excel.each do |row|

      i += 1

      # not process the header
      if i==1
        next
      end


      uebersetzung = row[4] || ''
      photo        = row[6] || ''
      literatur    = row[8] || ''
      seitezeile   = row[2] || ''
      band         = Integer(row[1]) || -1


      # if SzeneID doesn't exist
      if row[7] != nil and row[7] != ''
        szID = Integer(row[7])
      else
        szID = ''
      end

      #break if i==30

      # if uid doesn't exist
      if row[9] != nil and row[9] != ''
        uID = Integer(row[9])
      else
        uID = SecureRandom.random_number(100000000)


        Edfulog.new("ERROR", "UploadController-FL", "Keine UniqueId in Formular Tabelle vorhanden (Zeile #{i})", '', '', '', '')
      end


      f    = Formular.new
      f.id = ActiveRecord::Base.connection.execute("select nextval('formulare_id_seq')").first['nextval']

      f.uid                      = uID
      f.transliteration          = row[0] || ''
      #f.band            = band

      f.transliteration_nosuffix = row[3] || ''
      f.uebersetzung             = check_uebersetzungs_string(uebersetzung, uID)
      f.texttyp                  = row[5] || ''
      f.szeneID                  = szID

      # --- Stellen

      s                          = create_stellen(seitezeile, band, uID)
      # if s.class == Array
      #   s = s[0]

      seiteStart                 = s.seite_start
      band                       = s.band

      szenen = Szene.szenen["#{band}_#{seiteStart}"]


      if szenen != nil && szenen.size > 0

        szenen.each { |szene|

          s.szenen << szene
          szene.stellen << s

          # todo: required? ort.stellen...szenen
          f.szenen = Array.new if f.szenen == nil
          f.szenen << szene

          stz = StellenSzenen.fetch(s, szene)

          if stz.class == Array

            stz = stz[0]

            @stelle_szene_batch << stz

          end

        }

      end

      # @stelle_batch << s

      #end

      s.zugehoerigZu = f
      f.stellen << s


      # --- Photos

      if photo.class == Float
        photo = (photo.to_i).to_s
      end

      @photo_batch += manipulate_photo_string_and_create(photo, uID, f)

      f.photos.each { |p|
        fp          = FormularePhotos.new
        fp.formular = f
        fp.photo    = p
        @formular_photo_batch << fp
      }

      # --- Literaturen

      @literatur_batch += create_literaturen(uID, f)

      f.literaturen.each { |lit|
        fl           = FormulareLiteraturen.new
        fl.formular  = f
        fl.literatur = lit
        @formular_literatur_batch << fl
      }


      @formular_batch << f

      @formular_solr_batch << f.to_solr_string
      @formular_solr_batch += f.stellen.collect { |stelle| stelle.to_solr_string }

      # --- check batch size and write to db if max_size reached

      if @formular_batch.size == max_batch_size

        Formular.import @formular_batch
        @formular_batch.clear

        FormularePhotos.import @formular_photo_batch
        @formular_photo_batch.clear

        FormulareLiteraturen.import @formular_literatur_batch
        @formular_literatur_batch.clear

        #Stelle.import @stelle_batch
        #@stelle_batch.clear

        Photo.import @photo_batch
        @photo_batch.clear

        Literatur.import @literatur_batch
        @literatur_batch.clear
      end

    end


    # --- write batches to db

    # Stelle.import @stelle_batch if @stelle_batch.size > 0
    Photo.import @photo_batch if @photo_batch.size > 0
    Literatur.import @literatur_batch if @literatur_batch.size > 0
    FormularePhotos.import @formular_photo_batch if @formular_photo_batch.size > 0
    FormulareLiteraturen.import @formular_literatur_batch if @formular_literatur_batch.size > 0
    Formular.import @formular_batch if @formular_batch.size > 0


  end


  # todo move to Ort-Model/Helper (Topo.xls)
  def process_ort


    # excel               = Roo::Excel.new("public/uploads/Topo.xls")
    excel               = Roo::Excel.new("public/uploads/#{@uploaded_ort.original_filename}")
    excel.default_sheet = excel.sheets.first
    i                   = 0

    max_batch_size      = 500
    @ort_batch          = Array.new
    @ort_solr_batch     = Array.new
    # @stelle_batch             = Array.new if @stelle_batch == nil
    @stelle_szene_batch = Array.new if @stelle_szene_batch == nil

    excel.each do |row|

      i += 1

      # not process the header
      if i==1
        i += 1
        next
      end

      #break if i==100

      iStelle = row[0] ||= ''

      uid  = Integer(row[5]) || ''

      #puts uid

      o    = Ort.new
      o.id = ActiveRecord::Base.connection.execute("select nextval('orte_id_seq')").first['nextval']

      o.uid             = uid
      o.transliteration = row[1] || ''
      o.ort             = row[2] || ''
      o.lokalisation    = row[3] || ''
      o.anmerkung       = row[4] || ''


      if (iStelle == '')

        Edfulog.new("ERROR", "UploadController-OL", "Leere Stelle", "STELLE", iStelle, '', uid)
      else
        @stelle_szene_batch += manipulate_stelle_string_and_create(iStelle, uid, o)
      end


      @ort_batch << o


      @ort_solr_batch << o.to_solr_string
      @ort_solr_batch += o.stellen.collect { |stelle| stelle.to_solr_string }

      if @ort_batch.size == max_batch_size

        Ort.import @ort_batch
        @ort_batch.clear
      end

    end

    Ort.import @ort_batch if @ort_batch.size > 0
    @ort_batch.clear

  end


  # todo move to Gott-Model/Helper (Gods.xls)
  def process_gott


    # excel               = Roo::Excel.new("public/uploads/Gods.xls")
    excel               = Roo::Excel.new("public/uploads/#{@uploaded_gott.original_filename}")
    excel.default_sheet = excel.sheets.first
    i                   = 0

    max_batch_size      = 500
    @gott_batch         = Array.new
    @gott_solr_batch    = Array.new
    # @stelle_batch             = Array.new if @stelle_batch == nil
    @stelle_szene_batch = Array.new if @stelle_szene_batch == nil


    excel.each do |row|

      i += 1

      # not process the header
      if i==1
        i += 1
        next
      end


      #break if i==100


      uid        = Integer(row[9]) || ''
      seitezeile = row[7] || ''
      band       = row[6] || ''

      if seitezeile.class == Float
        seitezeile = seitezeile.to_s
        seitezeile.gsub!('.', ',')
      end

      g    = Gott.new
      g.id = ActiveRecord::Base.connection.execute("select nextval('goetter_id_seq')").first['nextval']

      g.uid                      = uid
      g.transliteration          = row[1] || ''
      g.transliteration_nosuffix = row[1] || ''
      g.ort                      = row[2] || ''
      g.eponym                   = row[3] || ''
      g.beziehung                = row[4] || ''
      g.funktion                 = row[5] || ''
      #band:                     band,
      g.anmerkung                = row[8] || ''


      stellen = manipulate_seitezeile_string_and_create_stelle(seitezeile, uid, band)

      stellen.each { |stelle|
        stelle.zugehoerigZu = g
        g.stellen << stelle


        #---


        seiteStart = stelle.seite_start
        b          = stelle.band

        szenen = Szene.szenen["#{b}_#{seiteStart}"]


        if szenen != nil && szenen.size > 0

          szenen.each { |szene|

            stelle.szenen << szene
            szene.stellen << stelle

            # todo: required? ort.stellen...szenen
            g.szenen = Array.new if g.szenen == nil
            g.szenen << szene

            stz = StellenSzenen.fetch(stelle, szene)

            if stz.class == Array

              stz = stz[0]

              @stelle_szene_batch << stz

            end
          }

        end

        #@stelle_batch << stelle


        #---


      }

      @gott_batch << g

      @gott_solr_batch << g.to_solr_string
      @gott_solr_batch += g.stellen.collect { |stelle| stelle.to_solr_string }


      if @gott_batch.size == max_batch_size

        Gott.import @gott_batch
        @gott_batch.clear
      end

    end

    Gott.import @gott_batch if @gott_batch.size > 0
    @gott_batch.clear

  end

  # todo move to Wort-Model/Helper (WL.xls)
  def process_wort

    #excel               = Roo::Excel.new("public/uploads/Woerterliste.xls")
    excel               = Roo::Excel.new("public/uploads/#{@uploaded_wort.original_filename}")

    # todo: nun mal die zweite Tabelle !!!
    #excel.default_sheet = excel.sheets.first
    excel.default_sheet = excel.sheets.second
    i                   = 0
    uniqueId            = false

    max_batch_size      = 500
    @wort_batch         = Array.new
    @word_solr_batch    = Array.new
    @wbberlin_batch     = Array.new

    # @stelle_batch             = Array.new if @stelle_batch == nil
    @stelle_szene_batch = Array.new if @stelle_szene_batch == nil

    excel.each do |row|

      i += 1

      # ignore the header
      if i==1

        if row[7] != nil && row[7].casecmp('UniqueId') == 0
          uniqueId = true
        else

          Edfulog.new("ERROR", "#{@uploaded_wort.original_filename}", "Keine UniqueId in Wort Tabelle vorhanden", '', '', '', '')
        end

        next

      end

      #break if i==3

      if row[2] != nil and row[2] != ''
        begin
          hierogl = Integer(row[2])
        rescue ArgumentError
          hierogl = row[2].to_s
        end
      else
        hierogl = ''
      end

      if uniqueId
        uid = Integer(row[7]) || ''
      else
        uid = i-1
      end

      belegstellenEdfu = row[4] || ''
      belegstellenWb   = row[5] || ''

      w    = Wort.new
      w.id = ActiveRecord::Base.connection.execute("select nextval('worte_id_seq')").first['nextval']

      w.uid                      = uid
      w.transliteration          = row[0] || ''
      w.transliteration_nosuffix = row[0] || ''
      w.uebersetzung             = row[1] || ''
      w.hieroglyph               = hierogl || ''
      w.weiteres                 = row[3] || ''
      w.belegstellenEdfu         = belegstellenEdfu
      w.belegstellenWb           = belegstellenWb
      w.anmerkung                = row[6] || ''

      stellen = manipulate_and_create_belegstellen_and_stelle(belegstellenEdfu, belegstellenWb, uid, w)

      stellen.each { |stelle|
        stelle.zugehoerigZu = w
        w.stellen << stelle


        #---

        seiteStart = stelle.seite_start
        b          = stelle.band

        szenen = Szene.szenen["#{b}_#{seiteStart}"]


        if szenen != nil && szenen.size > 0

          szenen.each { |szene|

            stelle.szenen << szene
            szene.stellen << stelle

            # todo: required? ort.stellen...szenen
            w.szenen = Array.new if w.szenen == nil
            w.szenen << szene

            stz = StellenSzenen.fetch(stelle, szene)
            if stz.class == Array

              stz = stz[0]
              @stelle_szene_batch << stz

            end
          }

        end

        # todo: find a better place for initialization
        # @stelle_batch = Array.new if @stelle_batch == nil
        #@stelle_batch << stelle

        #---

      }


      @wort_batch << w
      @wbberlin_batch << w.wbberlin

      @word_solr_batch << w.to_solr_string
      @word_solr_batch << w.wbberlin.to_solr_string
      @word_solr_batch += w.stellen.collect { |stelle| stelle.to_solr_string }


      if @wort_batch.size == max_batch_size

        Wort.import @wort_batch
        @wort_batch.clear
      end

    end

    Wort.import @wort_batch if @wort_batch.size > 0
    @wort_batch.clear

    Wbberlin.import @wbberlin_batch if @wbberlin_batch.size > 0
    @wbberlin_batch.clear

  end

  def save_szenen

    @szene_batch      = Array.new
    @szene_solr_batch = Array.new

    Szene.szenen.each { |key, value_array|
      value_array.each { |szene|
        @szene_batch << szene
        @szene_solr_batch << szene.to_solr_string
      }

    }


    Szene.import @szene_batch if @szene_batch.size > 0
    @szene_batch.clear

    sz     = StellenSzenen.stellenszenen
    sz_arr = Array.new

    sz.each { |key, value_array|
      sz_arr << value_array
    }


    StellenSzenen.import sz_arr if sz_arr.size > 0
    #@stelle_szene_batch.clear

  end

  def save_stellen

    @stelle_batch = Array.new
    #@stelle_solr_batch = Array.new

    Stelle.stellen.each { |stelle|

      @stelle_batch << stelle
      #@stelle_solr_batch << stelle.to_solr_string

    }

    Stelle.import @stelle_batch if @stelle_batch.size > 0
    @stelle_batch.clear


  end


  def process_szene

    # Szeneninformation aus CSV Dateien (aus Imagemap)

    #max_batch_size    = 1500
    #szene_bildDict    = Hash.new
    bilderColumnDict = Hash.new
    #@szene_solr_batch = Array.new

    #@szenebilder_batch = Array.new
    #@szene_batch       = Array.new
    #@stelle_batch      = Array.new


    CSV.foreach("Daten/tempelplan.csv", :col_sep => ';') do |bildRow|

      if bildRow[0] == 'image'

        # Spaltennummern für Felder feststellen
        i = 0
        bildRow.each { |value|
          bilderColumnDict[value] = i
          i                       += 1
        }

        next

      else


        dateiname       = bildRow[bilderColumnDict['image']]
        name            = bildRow[bilderColumnDict['label']]
        imagemap        = bildRow[bilderColumnDict['imagemap']]
        breite          = bildRow[bilderColumnDict['new_size_x']]
        hoehe           = bildRow[bilderColumnDict['new_size_y']]
        breite_original = bildRow[bilderColumnDict['orig_size_x']]
        hoehe_original  = bildRow[bilderColumnDict['orig_size_y']]
        offset_x        = bildRow[bilderColumnDict['offset_x']]
        offset_y        = bildRow[bilderColumnDict['offset_y']]


      end


      filePath = 'Daten/szenen/' + dateiname.gsub('.gif', '.csv')


      columnDict = {}


      CSV.foreach(filePath, :col_sep => ';') do |row|


        if row[0] == 'description'

          # Spaltennummern für Felder feststellen
          j = 0
          row.each { |value|
            columnDict[value] = j
            j                 += 1
          }

          next

        elsif row.size >= 12


          # --- stellen


          # stellen    = nil
          band       = 0
          seiteStart = 0

          if row[columnDict['volume']] != nil && row[columnDict['volume']] != ''

            band = row[columnDict['volume']]

            if band.to_i > 8

              Edfulog.new("ERROR", filePath, "Band > 8 (Position #{columnDict['volume']+1}, Band='#{band}')", '', row, '', '')

              next
            end

            unless seiteStart = row[columnDict['page']]
              seiteStart = 0
            end

            # stellen = Stelle.where(
            #     band:        band,
            #     seite_start: seiteStart
            # )

          end

          # -- szenen


          unless nummer = row[columnDict['plate']]
            nummer = 0
          end

          # if nummer.to_s.match(/[,\/\s]+/)
          #   temp = nummer.to_i
          #
          #   Edfulog.new("ERROR", filePath, "Fehlerhafte Plate (Position #{columnDict['plate']+1}, Szenennummer='#{nummer}')", '', row, '', '')
          #   nummer = temp
          # end


          unless beschreibung = row[columnDict['description']]
            beschreibung = ''
          end


          unless rect = row[columnDict['polygon']]
            rect = ''
          end

          if columnDict.has_key?('areacolor') and row[columnDict['areacolor']] == 2
            grau = true
          else
            grau = false
          end

          if columnDict.has_key?('polygon_original')
            polygon = row[columnDict['polygon_original']]
          else
            polygon = ''
          end


          sz = Szene.fetch(
              nummer,
              beschreibung,
              rect,
              row[columnDict['coord-x']],
              row[columnDict['coord-y']],
              row[columnDict['angleOfView']],
              row[columnDict['extent-width']],
              row[columnDict['height-percent']],
              row[columnDict['extent-height-percent']].to_f,
              grau,
              polygon,
              # aus szenebild
              name,
              dateiname,
              imagemap,
              breite,
              hoehe,
              offset_x,
              offset_y,
              breite_original,
              hoehe_original,
              band,
              seiteStart
          )


          # todo: szenen und stellen über stellen verbinden
          # todo: szenen_stellen Tabelle mit anpassen
          #sz.stellen << stellen unless stellen == nil

          #sz.id = ActiveRecord::Base.connection.execute("select nextval('szenen_id_seq')").first['nextval']

          # todo: per batch speichern
          #sz.save

          # todo: solr-batch erst nach verbindung mit stellen aufbauen (also ganz zum schluss)
          #@szene_solr_batch << sz.to_solr_string


          # if @szene_batch.size == max_batch_size
          #   Szene.import @szene_batch if @szene_batch.size > 0
          #   @szene_batch.clear
          # end

        else
          # [betrifft],  text,       spalte, original, neu, uid
          Edfulog.new("ERROR", filePath, "Weniger als 12 Spalten", '', row, '', '')
        end
      end

      #Szene.import @szene_batch if @szene_batch.size > 0

    end

  end

end
