require 'roo'
require 'securerandom'
require 'benchmark'

class UploadsController < ApplicationController

  before_action :set_upload, only: [:show, :edit, :update, :destroy]


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
    @upload = Upload.new(upload_params)


    # todo uncomment this
    uploaded_formular = params[:upload][:formular]
    uploaded_ort = params[:upload][:ort]
    uploaded_gott = params[:upload][:gott]
    uploaded_wort = params[:upload][:wort]
    email = params[:upload][:email]


    logger.debug "\t[DEBUG]  [UploadController] #{uploaded_formular.original_filename} #{uploaded_ort.original_filename} #{uploaded_gott.original_filename} #{uploaded_wort.original_filename} #{email}"


    n = 50000
    #Benchmark.bm(7) do |x|
    #x.report("File handling:") {

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

    #prepareDB
    #process_formular
    #process_ort
    #process_gott
    process_wort

  end

  def prepareDB
    Benchmark.bm(7) do |x|

      #--- DB

      x.report("delete data from db:") {
        Formular.destroy_all
        Gott.destroy_all
        Ort.destroy_all
        Wort.destroy_all
        WbBerlin.destroy_all
      }

      #--- solr

      x.report("delete solr docs:") {
        solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
        solr.update :data => '<delete><query>*:*</query></delete>'
        solr.update :data => '<commit/>'
      }

    end
  end

  # todo move to Formular/Helper (Formular.xls)
  def process_formular

    logger.debug "\t[DEBUG]  [UploadController] Processing formular table"

    formulare_batch = Array.new()
    formulare_batch_size = 1000

    n = 50000
    i = 1
    Benchmark.bm(7) do |x|


      logger.debug "\t[DEBUG]  [UploadController] #{Rails.root.join('public', 'uploads', 'Formular.xls')}"

      file = Rails.root.join('public', 'uploads', 'Formular.xls')
      excel = nil


      #excel = Roo::Excel.new(file.to_s)
      excel = Roo::Excel.new("public/uploads/Formular.xls")
      excel.default_sheet = excel.sheets.first

      x.report("create all formulars:") {
        excel.each do |row|

          # not process the header
          if i==1
            i += 1
            next
          end

          # todo replace this
          # break if i>1000

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
          end


          #formulare_batch << Formular.new(
          f = Formular.create(
              {
                  transliteration: row[0] || '',
                  band: Integer(row[1]) || -1,
                  seitezeile: row[2] || '',
                  transliteration_nosuffix: row[3] || '',
                  uebersetzung: row[4] || '',
                  texttyp: row[5] || '',
                  photo: row[6] || '',
                  photo_pfad: '',
                  photo_kommentar: '',
                  # szeneID changed to string from integer
                  szeneID: szID, # row[7] != '', # Integer(row[7]) || -1,
                  literatur: row[8] || '',
                  uid: uID
              }
          )

          # if formulare_batch.size >= formulare_batch_size
          #   Formular.import formulare_batch # , :validate => true
          #   #Formular.create formulare_batch
          #   formulare_batch.clear
          # end


          i += 1
        end

        #Formular.import formulare_batch unless formulare_batch == nil
      }
    end

  end

  # todo move to Ort-Model/Helper (Topo.xls)
  def process_ort

    logger.debug "\t[DEBUG]  [UploadController] Processing topo table"

    # todo replace this with uploaded file
    excel = Roo::Excel.new("public/uploads/Topo.xls")

    excel.default_sheet = excel.sheets.first

    i = 1

    Benchmark.bm(7) do |x|
      x.report("create all topos:") {
        excel.each do |row|

          # not process the header
          if i==1
            i += 1
            next
          end

          # todo replace this
          #break if i==15

          Ort.create(

              # changed to string from integer
              uid: Integer(row[5]) || '',
              iStelle: row[0] || '',
              transliteration: row[1] || '', # todo transliteration_highlight hinzufügen
              #transliteration_nosuffix: row[1] || '', # todo identisch mit transliteration ?
              ort: row[2] || '',
              lokalisation: row[3] || '',
              anmerkung: row[4] || ''

          )


          i += 1
        end
      }
    end
  end

  # todo move to Gott-Model/Helper (Gods.xls)
  def process_gott

    logger.debug "\t[DEBUG]  [UploadController] Processing gods table"

    excel = Roo::Excel.new("public/uploads/Gods.xls")

    excel.default_sheet = excel.sheets.first

    i = 1
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

          Gott.create(

              uid: Integer(row[9]) || '',
              transliteration: row[1] || '', # todo transliteration_highlight hinzufügen
              transliteration_nosuffix: row[1] || '', # todo identisch mit transliteration ?
              ort: row[2] || '',
              eponym: row[3] || '',
              beziehung: row[4] || '',
              funktion: row[5] || '',
              band: row[6] || '',
              seitezeile: row[7] || '', # todo wirklich in den index?
              anmerkung: row[8] || '',

          )


          i += 1
        end
      }
    end
  end

  # todo move to Wort-Model/Helper (WL.xls)
  def process_wort

    logger.debug "\t[DEBUG]  [UploadController] Processing word table"

    excel = Roo::Excel.new("public/uploads/WL.xls")

    excel.default_sheet = excel.sheets.first

    i = 1
    uniqueId = false

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

          # todo replace this
          #break if i==15


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

          uid changed to string from integer
          # Wort.create(
          #
          #     uid: uid,
          #     transliteration: row[0] || '', # todo transliteration_highlight hinzufügen
          #     transliteration_nosuffix: row[0] || '', # todo identisch mit transliteration ?
          #     uebersetzung: row[1] || '',
          #     # hieroglyph changed to string from integer
          #     hieroglyph: hierogl || '',
          #     weiteres: row[3] || '',
          #     belegstellenEdfu: row[4] || '', # todo in was indexiert? stelle_id?
          #     belegstellenWb: row[5] || '', # todo in was indexiert? stelle_berlin_id?
          #     anmerkung: row[6] || ''
          #
          # )


          logger.error "\t[DEBUG]  [UploadController]  uid: #{uid}\n transliteration: #{row[0] || ''}\n transliteration_nosuffix: #{row[0] || ''}\n uebersetzung: #{row[1] || ''}\n hieroglyph: #{hierogl || ''}\n weiteres: #{row[3] || ''}\n belegstellenEdfu: #{row[4] || ''}\n belegstellenWb: #{row[5] || ''}\n anmerkung: #{row[6] || ''}"


          i += 1
        end
      }
    end
  end

end
