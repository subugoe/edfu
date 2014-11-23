require 'roo'

class UploadsController < ApplicationController

  before_action :set_upload, only: [:show, :edit, :update, :destroy]


  # GET /uploads/new
  def new
    @upload = Upload.new
  end


  # POST /uploads
  # POST /uploads.json
  def create
    @upload = Upload.new(upload_params)

    processed = process_files

    respond_to do |format|
      #if @upload.save
      if processed
        format.html { redirect_to uploads_path, notice: 'Upload was successfully created.' }
      else
        format.html { redirect_to uploads_path, notice: 'Upload not created.' }

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
    #params.require(:upload).permit(:formular, :ort, :gott, :wort)
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
      break if i==15

      Formular.where(uid: Integer(row[9])).update_or_create(


        transliteration: row[0],
        band: Integer(row[1]),
        seitenzeile: row[2],
        transliteration_nosuffix: row[3],
        uebersetzung: row[4],
        texttyp: row[5],
        photo: row[6],
        photo_pfad: [],
        photo_kommentar: Array.new,
        szeneID: Integer(row[7]),
        literatur: row[8],
        uid: Integer(row[9])


      )
      i += 1
    end

    return true


    # xls = Roo::Spreadsheet.open('./edfu-data/Formular.xls')
    #
    # i = 1
    # arr = Array.new
    # xls.each(:uid => "uniqueID", :bd => 'BAND') { |hash|
    #
    #   if i==1
    #     i += 1
    #     next
    #   end
    #
    #   # todo replace this
    #   break if i==10
    #
    #
    #   arr << hash
    #   puts arr
    #
    #   i += 1
    # }

  end


end
