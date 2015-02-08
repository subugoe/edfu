class StellenController < ApplicationController


  before_action :set_stelle, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  # GET /stellen
  # GET /stellen.json
  def index
    # todo: limit 100?!
    @stellen = Stelle.all.limit(100)
  end

  # GET /stellen/1
  # GET /stellen/1.json
  def show
  end

  # # GET /stellen/new
  # def new
  #   @stelle = Stelle.new
  # end
  #
  # # GET /stellen/1/edit
  # def edit
  # end
  #
  # # POST /stellen
  # # POST /stellen.json
  # def create
  #   @stelle = Stelle.new(stelle_params)
  #
  #   respond_to do |format|
  #     if @stelle.save
  #       format.html { redirect_to @stelle, notice: 'Stelle was successfully created.' }
  #       format.json { render :show, status: :created, location: @stelle }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @stelle.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  #
  # # PATCH/PUT /stellen/1
  # # PATCH/PUT /stellen/1.json
  # def update
  #   respond_to do |format|
  #     if @stelle.update(stelle_params)
  #       format.html { redirect_to @stelle, notice: 'Stelle was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @stelle }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @stelle.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end
  #
  # # DELETE /stellen/1
  # # DELETE /stellen/1.json
  # def destroy
  #   @stelle.destroy
  #   respond_to do |format|
  #     format.html { redirect_to stellen_url, notice: 'Stelle was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end
  #

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_stelle
      @stelle = Stelle.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stelle_params
      params.require(:stelle).permit(:uid, :tempel, :band, :bandseite, :bandseitezeile, :seite_start, :seite_stop, :zeile_start, :zeile_stop, :stelle_anmerkung, :stelle_unsicher, :start, :stop, :zerstoerung, :freigegeben)
    end

end
