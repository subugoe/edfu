require 'roo'

class UploadsController < ApplicationController

  before_action :set_upload, only: [:show, :edit, :update, :destroy]

  # GET /uploads
  # GET /uploads.json
  def index
    @uploads = Upload.all
  end

  # GET /uploads/1
  # GET /uploads/1.json
  def show
  end

  # GET /uploads/new
  def new
    @upload = Upload.new
  end

  # GET /uploads/1/edit
  def edit
  end

  # POST /uploads
  # POST /uploads.json
  def create
    @upload = Upload.new(upload_params)

    process_files

    respond_to do |format|
      if @upload.save
        format.html { redirect_to @upload, notice: 'Upload was successfully created.' }
        format.json { render :show, status: :created, location: @upload }
      else
        format.html { render :new }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /uploads/1
  # PATCH/PUT /uploads/1.json
  def update
    respond_to do |format|
      if @upload.update(upload_params)
        format.html { redirect_to @upload, notice: 'Upload was successfully updated.' }
        format.json { render :show, status: :ok, location: @upload }
      else
        format.html { render :edit }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uploads/1
  # DELETE /uploads/1.json
  def destroy
    @upload.destroy
    respond_to do |format|
      format.html { redirect_to uploads_url, notice: 'Upload was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_upload
    @upload = Upload.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def upload_params
    params.require(:upload).permit(:formular, :ort, :gott, :wort)
  end

  def process_files

    excel = Roo::Excel.new("edfu-data/Formular.xls")

    excel.default_sheet = excel.sheets.first

    i = 1
    excel.each do |row|

      # not process the header
      if i==1
        i += 1
        next
      end

      # todo replace this
      break if i==10


      Formular.create(

          transliteration: row[0],          # TEXTMITSUF
          band: row[1],                     # BAND
          seitenzeile: row[2],              # SEITEZEILE
          transliteration_nosuffix: row[3], # TEXTOHNESU
          uebersetzung: row[4],             # TEXTDEUTSC
          texttyp: row[5],                  # TEXTTYP
          photo: row[6],                    # Photo
          photo_pfad: Array.new,
          photo_kommentar: Array.new,
          szeneID: row[7], # SzenenID
          literatur: row[8], # SekLit
          uniqueID_ row[9], # UniqueID


      )


      puts
      i += 1
    end

  end
end
