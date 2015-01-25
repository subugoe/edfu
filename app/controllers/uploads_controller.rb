# encoding: utf-8

require 'roo'
require 'securerandom'
require 'benchmark'
require 'verify_formular_helper'
require 'verify_ort_helper'
require 'verify_gott_helper'
require 'verify_wort_helper'
require 'scrape'
require 'stellen_helper'


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
    processed = false

    Benchmark.bm(7) do |x|
      x.report("process all:") {
        processed = process_files
      }
    end


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

    #process_formular
    # process_ort
    # process_gott
    # process_wort
    #
    process_szene
    #
    cleanupSolr
    updateSolr


  end

  def deleteDB
    Benchmark.bm(7) do |x|

      x.report("delete data from db:") {

        #User.delete_all

        Rails.cache.clear

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
        Szenebild.delete_all

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

    max_batch_size = 1500
    n              = 50000
    i              = 1

    @formular_solr_batch = Array.new

    @formular_batch           = Array.new
    @stelle_batch             = Array.new
    @photo_batch              = Array.new
    @literatur_batch          = Array.new
    @formular_photo_batch     = Array.new
    @formular_literatur_batch = Array.new

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

          # todo: remove this
          break if i==10

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
          f            = Formular.new


          f.id = ActiveRecord::Base.connection.execute("select nextval('formulare_id_seq')").first['nextval']

          f.uid                      = uID
          f.transliteration          = row[0] || ''
          f.band                     = band
          f.seitezeile               = seitezeile
          f.transliteration_nosuffix = row[3] || ''
          f.uebersetzung             = check_uebersetzungs_string(uebersetzung, uID)
          f.texttyp                  = row[5] || ''
          f.szeneID                  = szID

          # --- Stellen

          s                          = create_stellen(seitezeile, band, uID) # , f)
          if s.class == Array
            s = s[0]
            @stelle_batch << s
          end
          s.zugehoerigZu = f


          # --- Photos

          @photo_batch   += manipulate_photo_string_and_create(photo, uID, f)

          f.photos.each { |p|
            fp          = FormularePhotos.new
            fp.formular = f
            fp.photo    = p
            @formular_photo_batch << fp
          }

          # --- Literaturen

          f.literaturen.each { |lit|
            fl           = FormulareLiteraturen.new
            fl.formular  = f
            fl.literatur = lit
            @formular_literatur_batch << fl
          }
          @literatur_batch += create_literaturen(uID, f)


          @formular_batch << f

          @formular_solr_batch << f.to_solr_string
          @formular_solr_batch += f.stellen.collect { |stelle| stelle.to_solr_string }

          # --- check batch size and write to db if max_size reached

          if @formular_batch.size == max_batch_size
            Formular.import @formular_batch
            @formular_batch.clear
          end

          if @formular_photo_batch.size == max_batch_size
            FormularePhotos.import @formular_photo_batch
            @formular_photo_batch.clear
          end


          if @formular_literatur_batch.size == max_batch_size
            FormulareLiteraturen.import @formular_literatur_batch
            @formular_literatur_batch.clear
          end

          if @stelle_batch.size == max_batch_size
            Stelle.import @stelle_batch
            @stelle_batch.clear
          end

          if @photo_batch.size == max_batch_size
            Photo.import @photo_batch
            @photo_batch.clear
          end

          if @literatur_batch.size == max_batch_size
            Literatur.import @literatur_batch
            @literatur_batch.clear
          end

          i += 1
        end
      }


      # --- write batches to db

      Stelle.import @stelle_batch if @stelle_batch.size > 0
      Photo.import @photo_batch if @photo_batch.size > 0
      Literatur.import @literatur_batch if @literatur_batch.size > 0
      FormularePhotos.import @formular_photo_batch if @formular_photo_batch.size > 0
      FormulareLiteraturen.import @formular_literatur_batch if @formular_literatur_batch.size > 0
      Formular.import @formular_batch if @photo_batch.size > 0

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

    max_batch_size     = 1500
    szene_bildDict     = Hash.new
    bilderColumnDict   = Hash.new
    @szene_solr_batch  = Array.new

    @szenebilder_batch = Array.new
    @szene_batch       = Array.new
    @stelle_batch      = Array.new


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

        next

      else


        # name -> label
        # dateiname -> image
        # imagemap -> imagemap
        # breite -> new_size_x
        # hoehe -> new_size_y
        # breite_original -> orig_size_x
        # hoehe_original -> orig_size_y
        # offset_x -> offset_x
        # offset_y -> offset_y
        # name -> label


        recordSzeneBild = Szenebild.fetch(
            bildRow[bilderColumnDict['image']],
            bildRow[bilderColumnDict['label']],
            bildRow[bilderColumnDict['imagemap']],
            bildRow[bilderColumnDict['new_size_x']],
            bildRow[bilderColumnDict['new_size_y']],
            bildRow[bilderColumnDict['orig_size_x']],
            bildRow[bilderColumnDict['orig_size_y']],
            bildRow[bilderColumnDict['offset_x']],
            bildRow[bilderColumnDict['offset_y']]
        )
        if recordSzeneBild.class == Array
          # szeneBild is new
          recordSzeneBild = recordSzeneBild[0]
          @szenebilder_batch << recordSzeneBild
        end

      end

      # todo is the dateiname unique?
      # szene_bildDict[recordSzeneBild.dateiname] = recordSzeneBild
      # szene_bild_ID                                = recordSzeneBild.id

      filePath = 'Daten/szenen/' + recordSzeneBild.dateiname.gsub('.gif', '.csv')
      # with open(filePath, 'r') as csvFile:
      #                                  print u 'INFO CSV Datei »' + filePath + u '«'


      columnDict = {}


      CSV.foreach(filePath, :col_sep => ';') do |row|
        logger.info "\t[INFO]  [UploadController] CSV Datei: #{filePath}"

        if row[0] == 'description'

          # Spaltennummern für Felder feststellen
          j = 0
          row.each { |value|
            columnDict[value] = j
            j                 += 1
          }


        elsif row.size >= 12


          # --- stellen


          band           = ''
          bandseite      = ''
          bandseitezeile = ''
          seiteStart     = ''
          seiteStop      = ''
          zeileStart     = ''
          zeileStop      = ''
          anmerkung      = ''
          stopunsicher   = ''
          zerstoerung    = ''
          freigegeben    = ''

          stelle = nil

          if row[columnDict['volume']] != nil && row[columnDict['volume']] != ''


            band          = row[columnDict['volume']]


            if band.to_i > 8

              logger.error "\t[Error]  [UploadController] Fehlerhafter Band: #{row} (in #{filePath})."

              next
            end

            band_roemisch = dezimal_nach_roemisch(band)


            unless seiteStart = row[columnDict['page']]
              seiteStart = 0
            end

            if row.size >= 15
              seiteStop  = row[columnDict['page-to']]
              zeileStart = row[columnDict['line']]
              zeileStop  = row[columnDict['line-to']]

              bandseitezeile = "#{band_roemisch}, #{'%03i' % (seiteStart)}, #{'%02i' % (zeileStart)} - #{'%03i' % (seiteStop)}, #{'%02i' % (zeileStop)}"


            else
              seiteStop  = seiteStart
              zeileStart = 0
              zeileStop  = 30

              bandseitezeile = "#{band_roemisch}, #{'%03i' % (seiteStart)}, #{'%02i' % (zeileStart)}"


            end

            bandseite = "#{band_roemisch}, #{'%03i' % (seiteStart)}"

            anmerkung    = ''
            stopunsicher = 0
            zerstoerung  = 0

            freigegeben = StellenHelper.getFromBanddicet(band.to_i, 'freigegeben')


            stelle = Stelle.fetch(
                'Edfu',
                band,
                bandseite,
                bandseitezeile,
                seiteStart,
                seiteStop,
                zeileStart,
                zeileStop,
                anmerkung,
                stopunsicher,
                zerstoerung,
                freigegeben
            )

            if stelle.class == Array
              # szeneBild is new
              stelle = stelle[0]
              @stelle_batch << stelle
            end

          end



          # -- szenen


          unless nummer = row[columnDict['plate']]
            nummer = 0
          end

          if nummer.to_s.match(/[,\/\s]+/)
            temp = nummer.to_i
            logger.error "\t[Error]  [UploadController] Szenennummer (Plate) '#{nummer}' enthält Komma ',', slash '/' oder Leerzeichen #{row} (in #{filePath}). Verwendet wird #{temp}"
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

          # todo is plate unique? NO, e.g. there are 17 Szenes with szene_nummer = 113
          rSzene = Szene.fetch(
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
              polygon
          )

          if rSzene.class == Array
            # szeneBild is new
            rSzene = rSzene[0]
            @szene_batch << rSzene unless @szene_batch.include? rSzene
          end

          rSzene.stellen << stelle unless (stelle == nil || rSzene.stellen.include?(stelle))
          rSzene.szenebilder << recordSzeneBild unless rSzene.szenebilder.include? recordSzeneBild


          @szene_solr_batch << rSzene.to_solr_string


          if @szene_batch.size == max_batch_size

            Szene.import @szene_batch if @szene_batch.size > 0
            @szene_batch.clear

            Szenebild.import @szenebilder_batch if @szenebilder_batch.size > 0
            @szenebilder_batch.clear

            Stelle.import @stelle_batch if @stelle_batch.size > 0
            @stelle_batch.clear

          end

        else
          logger.error "\t[Error]  [UploadController] weniger als 12 Spalten in Zeile: #{row} (in #{filePath})"
        end
      end

      Szene.import @szene_batch if @szene_batch.size > 0
      Szenebild.import @szenebilder_batch if @szenebilder_batch.size > 0
      Stelle.import @stelle_batch if @stelle_batch.size > 0

    end


    # wird unter der Tabelle SZENE_BILD hinzugefügt
    #szene_bild = szene_bildDict.values()

  end

end
