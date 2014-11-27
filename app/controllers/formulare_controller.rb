class FormulareController < ApplicationController
  before_action :set_formular, only: [:show, :edit, :update, :destroy]

  # GET /formulare
  # GET /formulare.json
  def index
    @formulare = Formular.all
  end

  # GET /formulare/1
  # GET /formulare/1.json
  def show
  end

  # GET /formulare/new
  def new
    @formular = Formular.new
  end

  # GET /formulare/1/edit
  def edit
  end

  # POST /formulare
  # POST /formulare.json
  def create
    @formular = Formular.new(formular_params)

    respond_to do |format|
      if @formular.save
        format.html { redirect_to @formular, notice: 'Formular was successfully created.' }
        format.json { render :show, status: :created, location: @formular }
      else
        format.html { render :new }
        format.json { render json: @formular.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /formulare/1
  # PATCH/PUT /formulare/1.json
  def update
    respond_to do |format|
      if @formular.update(formular_params)
        format.html { redirect_to @formular, notice: 'Formular was successfully updated.' }
        format.json { render :show, status: :ok, location: @formular }
      else
        format.html { render :edit }
        format.json { render json: @formular.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /formulare/1
  # DELETE /formulare/1.json
  def destroy
    @formular.destroy
    respond_to do |format|
      format.html { redirect_to formulare_url, notice: 'Formular was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_formular
      @formular = Formular.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def formular_params
      params.require(:formular).permit(:uid, :transliteration, :transliteration_nosuffix, :uebersetzung, :texttyp, :photo, :photo_pfad, :photo_kommentar, :szeneID, :literatur, :band, :seitenzeile)
    end
end
