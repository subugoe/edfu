class WorteController < ApplicationController

  before_action :set_wort, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  # GET /worte
  # GET /worte.json
  def index
    # todo: limit 100?!
    @worte = Wort.all.limit(100)
  end

  # GET /worte/1
  # GET /worte/1.json
  def show
  end

  # GET /worte/new
  def new
    @wort = Wort.new
  end

  # GET /worte/1/edit
  def edit
  end

  # POST /worte
  # POST /worte.json
  def create
    @wort = Wort.new(wort_params)

    respond_to do |format|
      if @wort.save
        format.html { redirect_to @wort, notice: 'Wort was successfully created.' }
        format.json { render :show, status: :created, location: @wort }
      else
        format.html { render :new }
        format.json { render json: @wort.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /worte/1
  # PATCH/PUT /worte/1.json
  def update
    respond_to do |format|
      if @wort.update(wort_params)
        format.html { redirect_to @wort, notice: 'Wort was successfully updated.' }
        format.json { render :show, status: :ok, location: @wort }
      else
        format.html { render :edit }
        format.json { render json: @wort.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /worte/1
  # DELETE /worte/1.json
  def destroy
    @wort.destroy
    respond_to do |format|
      format.html { redirect_to worte_url, notice: 'Wort was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wort
      @wort = Wort.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wort_params
      params.require(:wort).permit(:uid, :transliteration, :transliteration_nosuffix, :uebersetzung, :hieroglyph, :weiteres, :belegstellenEdfu, :belegstellenWb, :anmerkung)
    end
end
