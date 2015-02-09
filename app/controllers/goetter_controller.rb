class GoetterController < ApplicationController

  before_action :set_gott, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  # GET /goetter
  # GET /goetter.json
  def index
    @goetter = Gott.all #.limit(100)
  end

  # GET /goetter/1
  # GET /goetter/1.json
  def show
  end

  # GET /goetter/new
  def new
    @gott = Gott.new
  end

  # GET /goetter/1/edit
  def edit
  end

  # POST /goetter
  # POST /goetter.json
  def create
    @gott = Gott.new(gott_params)

    respond_to do |format|
      if @gott.save
        format.html { redirect_to @gott, notice: 'Gott was successfully created.' }
        format.json { render :show, status: :created, location: @gott }
      else
        format.html { render :new }
        format.json { render json: @gott.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /goetter/1
  # PATCH/PUT /goetter/1.json
  def update
    respond_to do |format|
      if @gott.update(gott_params)
        format.html { redirect_to @gott, notice: 'Gott was successfully updated.' }
        format.json { render :show, status: :ok, location: @gott }
      else
        format.html { render :edit }
        format.json { render json: @gott.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /goetter/1
  # DELETE /goetter/1.json
  def destroy
    @gott.destroy
    respond_to do |format|
      format.html { redirect_to goetter_url, notice: 'Gott was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gott
      @gott = Gott.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gott_params
      params.require(:gott).permit(:uid, :transliteration, :transliteration_nosuffix, :ort, :eponym, :beziehung, :funktion, :band, :seitenzeile, :anmerkung)
    end
end
