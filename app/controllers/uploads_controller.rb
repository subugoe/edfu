require 'roo'
require 'securerandom'

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
    # uploaded_formular = params[:upload][:formular]
    # uploaded_ort = params[:upload][:ort]
    # uploaded_gott = params[:upload][:gott]
    # uploaded_wort = params[:upload][:wort]
    # email = params[:upload][:email]
    #
    #
    # logger.info "\t[INFO]  [Upload] #{uploaded_formular.original_filename} #{uploaded_ort.original_filename} #{uploaded_gott.original_filename} #{uploaded_wort.original_filename} #{email}"
    #
    #
    # File.open(Rails.root.join('public', 'uploads', uploaded_formular.original_filename), 'wb') do |file|
    #   file.write(uploaded_formular.read)
    # end
    #
    # File.open(Rails.root.join('public', 'uploads', uploaded_ort.original_filename), 'wb') do |file|
    #   file.write(uploaded_ort.read)
    # end
    #
    # File.open(Rails.root.join('public', 'uploads', uploaded_gott.original_filename), 'wb') do |file|
    #   file.write(uploaded_gott.read)
    # end
    #
    # File.open(Rails.root.join('public', 'uploads', uploaded_wort.original_filename), 'wb') do |file|
    #   file.write(uploaded_wort.read)
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

    prepareDB
    #process_formular
    process_ort
    #process_gott
    #process_wort

  end

  def prepareDB

    #--- DB

    #ActiveRecord::Base.connection.execute("Update sqlite_sequence set seq = 1 where name = 'formulare' OR name = 'goetter'
    #   OR name = 'photos' OR name = 'stellen' OR name = 'literaturen' OR name = 'orte' OR name = 'wb_berlins'
    #   OR name = 'worte'")

    Formular.destroy_all
    Gott.destroy_all
    Ort.destroy_all
    Wort.destroy_all
    WbBerlin.destroy_all

    #ActiveRecord::Base.connection.execute("Update sqlite_sequence set seq = 1 where name = 'formulare' OR name = 'goetter'
    #   OR name = 'photos' OR name = 'stellen' OR name = 'literaturen' OR name = 'orte' OR name = 'wb_berlins'
    #   OR name = 'worte'")

    #--- solr

    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
    solr.update :data => '<delete><query>*:*</query></delete>'
    solr.update :data => '<commit/>'


  end

  # todo move to Formular/Helper (Formular.xls)
  def process_formular

    logger.info "[Upload] #{Rails.root.join('public', 'uploads', 'Formular.xls')}"

    file = Rails.root.join('public', 'uploads', 'Formular.xls')

    #excel = Roo::Excel.new(file.to_s)
    excel = Roo::Excel.new("public/uploads/Formular.xls")


    excel.default_sheet = excel.sheets.first

    previousUID = 0
    i = 1
    excel.each do |row|

      # not process the header
      if i==1
        i += 1
        next
      end

      # todo replace this
      break if i>150

      # if SzeneID doesn't exist
      if row[7] != nil and row[7] != ''
        szID = Integer(row[7])
      else
        szID = ''
      end


      f = Formular.create(

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
          uid: Integer(row[9])

      )

      i += 1
    end

  end

  # todo move to Ort-Model/Helper (Topo.xls)
  def process_ort

    # todo replace this with uploaded file
    excel = Roo::Excel.new("public/uploads/Topo.xls")

    excel.default_sheet = excel.sheets.first

    i = 1
    excel.each do |row|

      # not process the header
      if i==1
        i += 1
        next
      end

      # todo replace this
      break if i==150

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

  end

  # todo move to Gott-Model/Helper (Gods.xls)
  def process_gott

    excel = Roo::Excel.new("public/uploads/Gods.xls")

    excel.default_sheet = excel.sheets.first

    i = 1
    excel.each do |row|

      # not process the header
      if i==1
        i += 1
        next
      end

      # todo replace this
      break if i==150

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

  end

  # todo move to Wort-Model/Helper (WL.xls)
  def process_wort

    excel = Roo::Excel.new("public/uploads/WL.xls")

    excel.default_sheet = excel.sheets.first

    i = 1
    excel.each do |row|

      # not process the header
      if i==1
        i += 1
        next
      end

      # todo replace this
      break if i==150


      if row[2] != nil and row[2] != ''
        begin
          hierogl = Integer(row[2])
        rescue ArgumentError
          hierogl = row[2].to_s
        end
      else
        hierogl = ''
      end

      # uid changed to string from integer
      Wort.create(

          uid: Integer(row[7]) || '',
          transliteration: row[0] || '', # todo transliteration_highlight hinzufügen
          transliteration_nosuffix: row[0] || '', # todo identisch mit transliteration ?
          uebersetzung: row[1] || '',
          # hieroglyph changed to string from integer
          hieroglyph: hierogl || '',
          weiteres: row[3] || '',
          belegstellenEdfu: row[4] || '', # todo in was indexiert? stelle_id?
          belegstellenWb: row[5] || '', # todo in was indexiert? stelle_berlin_id?
          anmerkung: row[6] || ''

      )


      i += 1
    end

  end

end
