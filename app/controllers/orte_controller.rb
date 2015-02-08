class OrteController < ApplicationController

  before_action :set_ort, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  # GET /orte
  # GET /orte.json
  def index
    # todo: limit 100?!
    @orte = Ort.all.limit(100)
  end

  # GET /orte/1
  # GET /orte/1.json
  def show
  end

  # GET /orte/new
  def new
    @ort = Ort.new
  end

  # GET /orte/1/edit
  def edit
  end

  # POST /orte
  # POST /orte.json
  def create
    @ort = Ort.new(ort_params)

    respond_to do |format|
      if @ort.save
        format.html { redirect_to @ort, notice: 'Ort was successfully created.' }
        format.json { render :show, status: :created, location: @ort }
      else
        format.html { render :new }
        format.json { render json: @ort.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orte/1
  # PATCH/PUT /orte/1.json
  def update
    respond_to do |format|
      if @ort.update(ort_params)
        format.html { redirect_to @ort, notice: 'Ort was successfully updated.' }
        format.json { render :show, status: :ok, location: @ort }
      else
        format.html { render :edit }
        format.json { render json: @ort.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orte/1
  # DELETE /orte/1.json
  def destroy
    @ort.destroy
    respond_to do |format|
      format.html { redirect_to orte_url, notice: 'Ort was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ort
      @ort = Ort.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ort_params
      params.require(:ort).permit(:uid, :stelle, :transliteration, :transliteration_nosuffix, :ort, :lokalisation, :anmerkung)
    end
end
