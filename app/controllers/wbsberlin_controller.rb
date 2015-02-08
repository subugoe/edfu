class WbsberlinController < ApplicationController


  before_action :set_wbberlin, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  # GET /wbs_berlin
  # GET /wbs_berlin.json
  def index
    # todo: limit 100?!
    @wbsberlin = Wbberlin.all.limit(100)
  end

  # GET /wbs_berlin/1
  # GET /wbs_berlin/1.json
  def show
  end

  # # GET /wb_berlins/new
  # def new
  #   @wb_berlin = Wbberlin.new
  # end
  #
  # # GET /wb_berlins/1/edit
  # def edit
  # end
  #
  # # POST /wb_berlins
  # # POST /wb_berlins.json
  # def create
  #   @wb_berlin = Wbberlin.new(wb_berlin_params)
  #
  #   respond_to do |format|
  #     if @wb_berlin.save
  #       format.html { redirect_to @wb_berlin, notice: 'Wb berlin was successfully created.' }
  #       format.json { render :show, status: :created, location: @wb_berlin }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @wb_berlin.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  #
  # # PATCH/PUT /wb_berlins/1
  # # PATCH/PUT /wb_berlins/1.json
  # def update
  #   respond_to do |format|
  #     if @wb_berlin.update(wb_berlin_params)
  #       format.html { redirect_to @wb_berlin, notice: 'Wb berlin was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @wb_berlin }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @wb_berlin.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /wbs_berlin/1
  # DELETE /wbs_berlin/1.json
  def destroy
    @wbberlin.destroy
    respond_to do |format|
      format.html { redirect_to wbberlins_url, notice: 'Wb berlin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_wbberlin
      @wbberlin = Wbberlin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wbberlin_params
      params.require(:wb_berlin).permit(:uid, :band, :seite_start, :seite_stop, :zeile_start, :zeile_stop, :wort_id)
    end

end
