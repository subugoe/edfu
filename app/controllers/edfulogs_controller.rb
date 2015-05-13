class EdfulogsController  < ApplicationController

    before_action :set_edfulog, only: [:show, :edit, :update, :destroy]
    before_filter :authenticate_user!

    # GET /edfulogs
    # GET /edfulogs.json
    def index
      @edfulogs = Edfulog.all #.limit(100)


    end

    # GET /edfulogs/1
    # GET /edfulogs/1.json
    def show
    end

    # # GET /edfulogs/new
    # def new
    #   @edfulog = Edfulog.new
    # end
    #
    # # GET /edfulogs/1/edit
    # def edit
    # end
    #
    # # POST /edfulogs
    # # POST /edfulogs.json
    # def create
    #   @edfulog = Edfulog.new(edfulog_params)
    #
    #   respond_to do |format|
    #     if @edfulog.save
    #       format.html { redirect_to @edfulog, notice: 'Edfulog was successfully created.' }
    #       format.json { render :show, status: :created, location: @edfulog }
    #     else
    #       format.html { render :new }
    #       format.json { render json: @edfulog.errors, status: :unprocessable_entity }
    #     end
    #   end
    # end
    #
    # # PATCH/PUT /edfulogs/1
    # # PATCH/PUT /edfulogs/1.json
    # def update
    #   respond_to do |format|
    #     if @edfulog.update(edfulog_params)
    #       format.html { redirect_to @edfulog, notice: 'Edfulog was successfully updated.' }
    #       format.json { render :show, status: :ok, location: @edfulog }
    #     else
    #       format.html { render :edit }
    #       format.json { render json: @edfulog.errors, status: :unprocessable_entity }
    #     end
    #   end
    # end
    #
    # # DELETE /edfulogs/1
    # # DELETE /edfulogs/1.json
    # def destroy
    #   @edfulog.destroy
    #   respond_to do |format|
    #     format.html { redirect_to edfulogs_url, notice: 'Edfulog was successfully destroyed.' }
    #     format.json { head :no_content }
    #   end
    # end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_edfulog
      @edfulog = Edfulog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def edfulog_params
      params.require(:edfulog).permit(:uid, :level, :edfutype, :text, :column, :old, :new)
    end
  end
