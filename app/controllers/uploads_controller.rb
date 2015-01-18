# encoding: utf-8

require 'roo'
require 'securerandom'
require 'benchmark'
require 'verify_formular_helper'
require 'verify_ort_helper'
require 'verify_gott_helper'
require 'verify_wort_helper'
require 'scrape'


class UploadsController < ApplicationController
  include VerifyFormularHelper
  include VerifyOrtHelper
  include VerifyGottHelper
  include VerifyWortHelper

  before_action :set_upload, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  # todo add multifile upload
  # todo add email for notification
  # todo add worker queue/thread for async processing

  # GET /uploads/new
  def new
    @upload = Upload.new
  end


  # POST /uploads
  # POST /uploads.json
  def create
    @upload           = Upload.new(upload_params)


    # todo: remove the next 4 lines
    # Scrape.new
    # respond_to do |format|
    #   format.html { redirect_to uploads_path, notice: "Upload was successfully created." }
    # end


    uploaded_formular = params[:upload][:formular]
    uploaded_ort      = params[:upload][:ort]
    uploaded_gott     = params[:upload][:gott]
    uploaded_wort     = params[:upload][:wort]
    email             = params[:upload][:email]


    logger.debug "\t[DEBUG]  [UploadController] #{uploaded_formular.original_filename} #{uploaded_ort.original_filename} #{uploaded_gott.original_filename} #{uploaded_wort.original_filename} #{email}"


    n = 50000
    #Benchmark.bm(7) do |x|
    #x.report("File handling:") {

    # todo check tables (all columns?)

    File.open(Rails.root.join('public', 'uploads', uploaded_formular.original_filename), 'wb') do |file|
      file.write(uploaded_formular.read)
    end

    File.open(Rails.root.join('public', 'uploads', uploaded_ort.original_filename), 'wb') do |file|
      file.write(uploaded_ort.read)
    end

    File.open(Rails.root.join('public', 'uploads', uploaded_gott.original_filename), 'wb') do |file|
      file.write(uploaded_gott.read)
    end

    File.open(Rails.root.join('public', 'uploads', uploaded_wort.original_filename), 'wb') do |file|
      file.write(uploaded_wort.read)
    end

    #}
    # end


    processed = process_files

    respond_to do |format|
      #if @upload.save
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

    deleteDB

    process_formular
    process_ort
    process_gott
    process_wort

    process_szene

    cleanupSolr
    updateSolr


  end

  def deleteDB
    Benchmark.bm(7) do |x|

      x.report("delete data from db:") {
        User.delete_all
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

      }
    end
  end

  def cleanupSolr

    Benchmark.bm(7) do |x|
      x.report("delete solr docs:") {
        solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
        solr.update :data => '<delete><query>*:*</query></delete>'
        solr.update :data => '<commit/>'
      }
    end
  end

  def updateSolr
    Benchmark.bm(7) do |x|

      x.report("add words to solr:") {
        if (@word_solr_batch != nil && @word_solr_batch.size > 0)
          add_to_solr(@word_solr_batch)
        end
      }
      x.report("add gods to solr:") {
        if @gott_solr_batch != nil && @gott_solr_batch.size > 0
          add_to_solr(@gott_solr_batch)
        end
      }
      x.report("add topos to solr:") {
        if @ort_solr_batch != nil && @ort_solr_batch.size > 0
          add_to_solr(@ort_solr_batch)
        end
      }
      x.report("add formulars to solr:") {
        if @formular_solr_batch != nil && @formular_solr_batch.size > 0
          add_to_solr(@formular_solr_batch)
        end
      }

      puts "update solr size: #{@szene_solr_batch.size}"

      x.report("add scenes to solr:") {
        if @szene_solr_batch != nil && @szene_solr_batch.size > 0
          add_to_solr(@szene_solr_batch)
        end
      }

      # todo: was ist schneller? zuvor, oder so?
      # x.report("add to solr:") {
      #     add_to_solr(@word_solr_batch + @gott_solr_batch + @ort_solr_batch + @formular_solr_batch)
      #}

    end
  end

  def add_to_solr(solr_string_array)

    # todo extract
    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
    solr.add (solr_string_array)
    solr.commit
  end

  # todo move to Formular/Helper (Formular.xls)
  def process_formular

    logger.debug "\t[DEBUG]  [UploadController] Processing formular table"
    #
    # formulare_batch = Array.new()
    #
    # literaturen = Array.new
    # literatur_batch = Array.new()
    # literatur_hash = Hash.new()
    #
    #
    # photos = Array.new
    # photo_batch = Array.new()
    #
    # stellen = Array.new
    # stellen_batch = Array.new

    #formulare_batch_size = 1000

    n = 50000
    i = 1

    @formular_solr_batch = Array.new

    Benchmark.bm(7) do |x|

      logger.debug "\t[DEBUG]  [UploadController] #{Rails.root.join('public', 'uploads', 'Formular.xls')}"

      # file = Rails.root.join('public', 'uploads', 'Formular.xls')
      # excel = nil


      #excel = Roo::Excel.new(file.to_s)
      excel               = Roo::Excel.new("public/uploads/Formular.xls")
      excel.default_sheet = excel.sheets.first

      x.report("create all formulars:") {
        excel.each do |row|

          # not process the header
          if i==1
            i += 1
            next
          end

          # if SzeneID doesn't exist
          if row[7] != nil and row[7] != ''
            szID = Integer(row[7])
          else
            szID = ''
          end

          # if uid doesn't exist
          # todo use string
          if row[9] != nil and row[9] != ''
            uID = Integer(row[9])
          else
            uID = SecureRandom.random_number(100000000)
            # todo logger.error "\t[ERROR]  [UploadController] Keine UniqueId in Wort Tabelle vorhanden"
          end


          uebersetzung = row[4] || ''
          photo        = row[6].to_s || ''
          literatur    = row[8] || ''
          seitezeile   = row[2] || ''
          band         = Integer(row[1]) || -1

          # in batch und dann bulk ingest, nebenläufig ausführen
          f            = Formular.new (
                                          {
                                              uid:                      uID,
                                              transliteration:          row[0] || '',
                                              band:                     band,
                                              seitezeile:               seitezeile,
                                              transliteration_nosuffix: row[3] || '',
                                              uebersetzung:             check_uebersetzungs_string(uebersetzung, uID),
                                              texttyp:                  row[5] || '',
                                              szeneID:                  szID
                                          }
                                      )
          # formulare.each ... {
          create_stellen(seitezeile, band, uID, f)
          manipulate_photo_string_and_create(photo, uID, f)
          create_literaturen(uID, f)

          # ... }

          f.save

          @formular_solr_batch << f.to_solr_string
          @formular_solr_batch += f.stellen.collect { |stelle| stelle.to_solr_string }


          i += 1
        end
      }


      #x.report("write formular batch to db:") {
      #  Formular.import formulare_batch #unless formulare_batch == nil
      #}

    end

  end

  # todo move to Ort-Model/Helper (Topo.xls)
  def process_ort

    logger.debug "\t[DEBUG]  [UploadController] Processing topo table"

    # todo replace this with uploaded file
    excel               = Roo::Excel.new("public/uploads/Topo.xls")
    excel.default_sheet = excel.sheets.first
    i                   = 1

    @ort_solr_batch = Array.new

    Benchmark.bm(7) do |x|
      x.report("create all topos:") {
        excel.each do |row|

          # not process the header
          if i==1
            i += 1
            next
          end

          iStelle = row[0] || ''
          uid     = Integer(row[5]) || ''

          o = Ort.new(

              # changed to string from integer
              uid:             uid,
              #iStelle: row[0] || '',
              transliteration: row[1] || '', # todo transliteration_highlight hinzufügen
              #transliteration_nosuffix: row[1] || '', # todo identisch mit transliteration ?
              ort:             row[2] || '',
              lokalisation:    row[3] || '',
              anmerkung:       row[4] || ''

          )

          manipulate_stelle_string_and_create(iStelle, uid, o)

          o.save

          @ort_solr_batch << o.to_solr_string
          @ort_solr_batch += o.stellen.collect { |stelle| stelle.to_solr_string }


          i += 1
        end
      }
    end
  end

  # todo move to Gott-Model/Helper (Gods.xls)
  def process_gott

    logger.debug "\t[DEBUG]  [UploadController] Processing gods table"

    excel               = Roo::Excel.new("public/uploads/Gods.xls")
    excel.default_sheet = excel.sheets.first
    i                   = 1

    @gott_solr_batch = Array.new


    Benchmark.bm(7) do |x|
      x.report("create all gods:") {
        excel.each do |row|

          # not process the header
          if i==1
            i += 1
            next
          end

          # todo replace this
          #break if i==15

          #puts  "god uid: #{Integer(row[9])}"

          uid        = Integer(row[9]) || ''
          seitezeile = row[7] || ''
          band       = row[6] || ''

          g = Gott.new(

              uid:                      uid,
              transliteration:          row[1] || '', # todo transliteration_highlight hinzufügen
              transliteration_nosuffix: row[1] || '', # todo identisch mit transliteration ?
              ort:                      row[2] || '',
              eponym:                   row[3] || '',
              beziehung:                row[4] || '',
              funktion:                 row[5] || '',
              band:                     band,
              seitezeile:               seitezeile,
              anmerkung:                row[8] || '',

          )

          manipulate_seitezeile_string_and_create_stelle(seitezeile, uid, band, g)

          g.save

          @gott_solr_batch << g.to_solr_string
          @gott_solr_batch += g.stellen.collect { |stelle| stelle.to_solr_string }

          i += 1
        end
      }
    end
  end

  # todo move to Wort-Model/Helper (WL.xls)
  def process_wort

    logger.debug "\t[DEBUG]  [UploadController] Processing word table"

    excel               = Roo::Excel.new("public/uploads/WL.xls")
    excel.default_sheet = excel.sheets.first
    i                   = 1
    uniqueId            = false

    @word_solr_batch = Array.new

    Benchmark.bm(7) do |x|
      x.report("create all words:") {
        excel.each do |row|

          # ignore the header
          if i==1
            if row[7] != nil && row[7].casecmp('UniqueId') == 0
              uniqueId = true
            else
              logger.error "\t[ERROR]  [UploadController] Keine UniqueId in Wort Tabelle vorhanden"
            end

            i += 1
            next

          end

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
          w.transliteration          = row[0] || '' # todo transliteration_highlight hinzufügen
          w.transliteration_nosuffix = row[0] || '' # todo identisch mit transliteration ?
          w.uebersetzung             = row[1] || ''
          # hieroglyph changed to string from integer
          w.hieroglyph               = hierogl || ''
          w.weiteres                 = row[3] || ''
          w.belegstellenEdfu         = belegstellenEdfu # todo in was indexiert? stelle_id?
          w.belegstellenWb           = belegstellenWb # todo in was indexiert? stelle_berlin_id?
          w.anmerkung                = row[6] || ''

          manipulate_and_create_belegstellen_and_stelle(belegstellenEdfu, belegstellenWb, uid, w)

          w.save

          @word_solr_batch << w.to_solr_string
          @word_solr_batch << w.wbberlin.to_solr_string
          @word_solr_batch += w.stellen.collect { |stelle| stelle.to_solr_string }

          i += 1
        end
      }
    end
  end


  def process_szene

    # Szeneninformation aus CSV Dateien (aus Imagemap)

    szene_bildDict    = Hash.new
    bilderColumnDict  = Hash.new
    @szene_solr_batch = Array.new

    CSV.foreach("Daten/tempelplan.csv", :col_sep => ';') do |bildRow|
      # with open('Daten/tempelplan.csv', 'rb') as bilderListeCSV:
      #                                                bilderListeReader = UnicodeReader(bilderListeCSV, delimiter=';')


      # for bildRow in bilderListeReader :

      if bildRow[0] == 'image'
        # Spaltennummern für Felder feststellen
        i = 0
        bildRow.each { |value|
          bilderColumnDict[value] = i
          i                       += 1
        }

      else
        recordSzeneBild = Szenebild.find_or_create_by(
            dateiname: bildRow[bilderColumnDict['image']]

        ) do |szenebild|
          szenebild.name            = bildRow[bilderColumnDict['label']]
          szenebild.imagemap        = bildRow[bilderColumnDict['imagemap']]
          szenebild.breite          = bildRow[bilderColumnDict['new_size_x']]
          szenebild.hoehe           = bildRow[bilderColumnDict['new_size_y']]
          szenebild.breite_original = bildRow[bilderColumnDict['orig_size_x']]
          szenebild.hoehe_original  = bildRow[bilderColumnDict['orig_size_y']]
          szenebild.offset_x        = bildRow[bilderColumnDict['offset_x']]
          szenebild.offset_y        = bildRow[bilderColumnDict['offset_y']]
          szenebild.name            = bildRow[bilderColumnDict['label']]
        end

        # todo: romove this
        puts bildRow[bilderColumnDict['image']]


        # todo is the dateiname unique?
        szene_bildDict[recordSzeneBild['dateiname']] = recordSzeneBild
        szene_bild_ID                                = recordSzeneBild['uid']

        filePath   = 'Daten/szenen/' + recordSzeneBild['dateiname'].gsub('.gif', '.csv')
        # with open(filePath, 'r') as csvFile:
        #                                  print u 'INFO CSV Datei »' + filePath + u '«'


        columnDict = {}

        CSV.foreach(filePath, :col_sep => ';') do |row|
          logger.info "\t[INFO]  [UploadController] CSV Datei: #{filePath}"


          #reader = UnicodeReader(csvFile, delimiter=';')

          #for row in reader :

          if row[0] == 'description'
            # Spaltennummern für Felder feststellen
            j = 0
            row.each { |value|
              columnDict[value] = j
              j                 += 1
            }

          elsif row.size >= 12
            #szeneID  = szene.size
            #stelleID = stelle.size


            unless nummer = row[columnDict['plate']]
              nummer = 0
            end

            if nummer.match(/[,\s]+/)
              logger.error "\t[Error]  [UploadController] Szenennummer '#{nummer}' enthält Komma oder Leerzeichen #{row} (in #{filePath})"
              nummer = nummer.to_i
            end


            unless beschreibung = row[columnDict['description']]
              beschreibung = ''
            end


            unless rect = row[columnDict['polygon']]
              rect = ''
            end


            # todo is plate unique? NO, e.g. there are 17 Szenes with szene_nummer = 113
            rSzene = Szene.new

            rSzene.nummer       = nummer
            rSzene.beschreibung = beschreibung
            rSzene.rect         = rect

            rSzene.koordinate_x = row[columnDict['coord-x']]
            rSzene.koordinate_y = row[columnDict['coord-y']]
            rSzene.blickwinkel  = row[columnDict['angleOfView']]
            rSzene.breite       = row[columnDict['extent-width']]
            rSzene.prozent_z    = row[columnDict['height-percent']]
            rSzene.hoehe        = (row[columnDict['extent-height-percent']]).to_f

            if columnDict.has_key?('areacolor') and row[columnDict['areacolor']] == 2
              rSzene.grau = true
            else
              rSzene.grau = false
            end

            if columnDict.has_key?('polygon_original')
              rSzene.polygon = row[columnDict['polygon_original']]
            else
              rSzene.polygon = ''
            end

            rSzene.save

            # formular.photos << p unless formular.photos.include? p
            rSzene.szenebilder << recordSzeneBild unless rSzene.szenebilder.include? recordSzeneBild

#            @szene_solr_batch << rSzene.to_solr_string

            #szene      += [rSzene]

            # szene created

            seiteStart = row[columnDict['page']]
            seiteStop  = seiteStart
            zeileStart = 0
            zeileStop  = 30
            if row.size >= 15
              seiteStop  = row[columnDict['page-to']]
              zeileStart = row[columnDict['line']]
              zeileStop  = row[columnDict['line-to']]
            end
            if row[columnDict['volume']] != ''

              # rStelle             = Stelle.new
              # rStelle.band        = row[columnDict['volume']]
              # rStelle.seite_start = seiteStart
              # rStelle.zeile_start = zeileStart
              # rStelle.seite_stop  = seiteStop
              # rStelle.zeile_stop  = zeileStop
              #
              # rStelle.stelle_anmerkung = ''
              # rStelle.stelle_unsicher  = 0
              # rStelle.zerstoerung      = 0
              # # todo: check: freigegeben? tempel?, bandseite?, bandseitezeile?
              #
              # rStelle.save

              # todo: Stelle creation at other places with find_or_create_by
              # rStelle = Stelle.find_or_create_by(
              #     band:    row[columnDict['volume']],
              #     seite_start: seiteStart,
              #     zeile_start: zeileStart,
              #     seite_stop:  seiteStop,
              #     zeile_stop:  zeileStop
              # ) do |stelle|
              #   stelle.stelle_anmerkung     = ''
              #   stelle.stelle_unsicher = 0
              #   stelle.zerstoerung   = 0
              #   # todo: check: freigegeben? tempel?, bandseite?, bandseitezeile?
              # end

              # rStelle = Stelle.find_by(
              #     band:        row[columnDict['volume']],
              #     seite_start: seiteStart
              # )
              #
              # if rStelle != nil
              #   puts rStelle
              #   puts "#{rStelle.band}, #{rStelle.seite_start}"
              #   rStelle.szenen << rSzene unless rStelle.szenen.include? rSzene
              #   if rStelle.band == "5" && rStelle.seite_start == "86"
              #     puts rStelle.szenen.size
              #   end
              #
              #   @szene_solr_batch << rStelle.to_solr_string
              #
              # end

              stellen = Stelle.where(seite_start: seiteStart, band: row[columnDict['volume']])

              # todo: test existence?
              #rStelle.szenen << rSzene unless rStelle.szenen.include? rSzene
              rSzene.stellen << stellen

              @szene_solr_batch << rSzene.to_solr_string
              # @szene_solr_batch += rSzene.stellen.collect { |stelle| stelle.to_solr_string }


              # stelle           += [rStelle]

              # stelle created


              # szene_has_stelle += [{
              #                          'uid_local'   => szeneID,
              #                          'uid_foreign' => stelleID
              #                      }]
            end
          else
            logger.error "\t[Error]  [UploadController] weniger als 12 Spalten in Zeile: #{row} (in #{filePath})"
          end
        end
      end


    end

    # wird unter der Tabelle SZENE_BILD hinzugefügt
    #szene_bild = szene_bildDict.values()

    puts "process_szene size: #{@szene_solr_batch.size}"

  end

end
