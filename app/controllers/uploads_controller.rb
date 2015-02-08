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
  include VerifyFormularHelper
  include VerifyOrtHelper
  include VerifyGottHelper
  include VerifyWortHelper

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


    processed = false

    #Benchmark.bm(7) do |x|
    #  x.report("processing all:") {
    processed = process_files
    #  }
    #end

    respond_to do |format|

      if processed
        format.html { redirect_to uploads_path, notice: "Upload was successfully created." }
      else
        format.html { redirect_to uploads_path, alert: "Upload not created!" }
      end

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

    #Benchmark.bm(7) do |x|


    deleteDB


    # x.report("formular  processing:") {
    process_formular
    # }

    # x.report("topo  processing:") {
    process_ort
    # }

    # x.report("gods  processing:") {
    process_gott
    # }

    # x.report("word processing:") {
    process_wort
    # }

    # x.report("scenes processing:") {
    process_szene
    # }

    # x.report("solr processing:") {
    cleanupSolr
    updateSolr
    # }


    #end
  end

  def deleteDB

    # User.delete_all

    Rails.cache.clear

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


  end

  def cleanupSolr

    #solr = RSolr.connect :url => "http://#{SOLR_DOMAIN}:#{SOLR_PORT}/solr/collection1"
    solr = RSolr.connect :url => "http://localhost:8983/solr/collection1"
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


  end


  def add_to_solr(solr_string_array)

    #solr = RSolr.connect :url => "http://#{SOLR_DOMAIN}:#{SOLR_PORT}/solr/collection1"
    solr = RSolr.connect :url => "http://localhost:8983/solr/collection1"
    solr.add (solr_string_array)
    solr.commit

  end


  def process_formular


    max_batch_size = 1500
    n              = 50000
    i              = 0

    @formular_solr_batch = Array.new

    @formular_batch           = Array.new
    @stelle_batch             = Array.new
    @photo_batch              = Array.new
    @literatur_batch          = Array.new
    @formular_photo_batch     = Array.new
    @formular_literatur_batch = Array.new


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

      #break if i==1500

      # if uid doesn't exist
      if row[9] != nil and row[9] != ''
        uID = Integer(row[9])
      else
        uID = SecureRandom.random_number(100000000)


        Edfulog.new("ERROR", "UploadController-FL", "Keine UniqueId in Formular Tabelle vorhanden (Zeile #{i})", '', '', '', '')
      end


      f = Formular.new


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
      if s.class == Array
        s = s[0]
        @stelle_batch << s
      end

      s.zugehoerigZu = f
      #f.bandseite      = s.bandseite
      #f.bandseitezeile = s.bandseitezeile

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

        Stelle.import @stelle_batch
        @stelle_batch.clear

        Photo.import @photo_batch
        @photo_batch.clear

        Literatur.import @literatur_batch
        @literatur_batch.clear
      end

      i += 1
    end


    # --- write batches to db

    Stelle.import @stelle_batch if @stelle_batch.size > 0
    Photo.import @photo_batch if @photo_batch.size > 0
    Literatur.import @literatur_batch if @literatur_batch.size > 0
    FormularePhotos.import @formular_photo_batch if @formular_photo_batch.size > 0
    FormulareLiteraturen.import @formular_literatur_batch if @formular_literatur_batch.size > 0
    Formular.import @formular_batch if @photo_batch.size > 0


  end


  # todo move to Ort-Model/Helper (Topo.xls)
  def process_ort


    # excel               = Roo::Excel.new("public/uploads/Topo.xls")
    excel               = Roo::Excel.new("public/uploads/#{@uploaded_ort.original_filename}")
    excel.default_sheet = excel.sheets.first
    i                   = 1

    @ort_solr_batch = Array.new

    excel.each do |row|

      # not process the header
      if i==1
        i += 1
        next
      end

      #break if i==100

      iStelle = row[0] ||= ''

      uid = Integer(row[5]) || ''

      o = Ort.new(

          uid:             uid,
          transliteration: row[1] || '',
          ort:             row[2] || '',
          lokalisation:    row[3] || '',
          anmerkung:       row[4] || ''

      )


      if (iStelle == '')

        Edfulog.new("ERROR", "UploadController-OL", "Leere Stelle", "STELLE", iStelle, '', uid)
      else
        manipulate_stelle_string_and_create(iStelle, uid, o)
      end


      o.save

      @ort_solr_batch << o.to_solr_string
      @ort_solr_batch += o.stellen.collect { |stelle| stelle.to_solr_string }


      i += 1
    end

  end


  # todo move to Gott-Model/Helper (Gods.xls)
  def process_gott


    # excel               = Roo::Excel.new("public/uploads/Gods.xls")
    excel               = Roo::Excel.new("public/uploads/#{@uploaded_gott.original_filename}")
    excel.default_sheet = excel.sheets.first
    i                   = 1

    @gott_solr_batch = Array.new


    excel.each do |row|

      # not process the header
      if i==1
        i += 1
        next
      end


      #break if i==100


      uid        = Integer(row[9]) || ''
      seitezeile = row[7] || ''
      band       = row[6] || ''

      g = Gott.new(

          uid:                      uid,
          transliteration:          row[1] || '',
          transliteration_nosuffix: row[1] || '',
          ort:                      row[2] || '',
          eponym:                   row[3] || '',
          beziehung:                row[4] || '',
          funktion:                 row[5] || '',
          #band:                     band,
          anmerkung:                row[8] || '',

      )

      stellen = manipulate_seitezeile_string_and_create_stelle(seitezeile, uid, band)

      stellen.each { |stelle|
        stelle.zugehoerigZu = g
        g.stellen << stelle
      }

      g.save

      @gott_solr_batch << g.to_solr_string
      @gott_solr_batch += g.stellen.collect { |stelle| stelle.to_solr_string }

      i += 1
    end

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

    @word_solr_batch = Array.new

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

      #break if i==100

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

      w                          = Wort.new
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
      }

      w.save

      @word_solr_batch << w.to_solr_string
      @word_solr_batch << w.wbberlin.to_solr_string
      @word_solr_batch += w.stellen.collect { |stelle| stelle.to_solr_string }


    end

  end


  def process_szene

    # Szeneninformation aus CSV Dateien (aus Imagemap)

    max_batch_size    = 1500
    szene_bildDict    = Hash.new
    bilderColumnDict  = Hash.new
    @szene_solr_batch = Array.new

    @szenebilder_batch = Array.new
    @szene_batch       = Array.new
    @stelle_batch      = Array.new


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


          stellen = nil

          if row[columnDict['volume']] != nil && row[columnDict['volume']] != ''

            band = row[columnDict['volume']]

            if band.to_i > 8


              Edfulog.new("ERROR", filePath, "Band > 8 (Spalte #{columnDict['volume']})", '', row, '', '')

              next
            end

            unless seiteStart = row[columnDict['page']]
              seiteStart = 0
            end

            stellen = Stelle.where(
                band:        band,
                seite_start: seiteStart
            )

          end

          # -- szenen


          unless nummer = row[columnDict['plate']]
            nummer = 0
          end

          if nummer.to_s.match(/[,\/\s]+/)
            temp = nummer.to_i

            Edfulog.new("ERROR", filePath, "Fehlerhafte Szenennummer (Spalte #{columnDict['plate']})", '', row, '', '')
            nummer = temp
          end


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


          sz = Szene.new(
              nummer:          nummer,
              beschreibung:    beschreibung,
              rect:            rect,
              koordinate_x:    row[columnDict['coord-x']],
              koordinate_y:    row[columnDict['coord-y']],
              blickwinkel:     row[columnDict['angleOfView']],
              breite:          row[columnDict['extent-width']],
              prozent_z:       row[columnDict['height-percent']],
              hoehe:           row[columnDict['extent-height-percent']].to_f,
              grau:            grau,
              polygon:         polygon,
              # aus szenebild
              name:            name,
              dateiname:       dateiname,
              imagemap:        imagemap,
              bild_breite:     breite,
              bild_hoehe:      hoehe,
              offset_x:        offset_x,
              offset_y:        offset_y,
              breite_original: breite_original,
              hoehe_original:  hoehe_original
          )


          sz.stellen << stellen unless stellen == nil

          sz.id = ActiveRecord::Base.connection.execute("select nextval('szenen_id_seq')").first['nextval']

          sz.save

          @szene_solr_batch << sz.to_solr_string


          if @szene_batch.size == max_batch_size
            Szene.import @szene_batch if @szene_batch.size > 0
            @szene_batch.clear
          end

        else
          # [betrifft],  text,       spalte, original, neu, uid
          Edfulog.new("ERROR", filePath, "Weniger als 12 Spalten", '', row, '', '')
        end
      end

      Szene.import @szene_batch if @szene_batch.size > 0

    end

  end

end
