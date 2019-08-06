class RadarDataController < ApplicationController
  before_action :set_radar_datum, only: [:download, :raw_json, :show, :edit, :update, :destroy]

  # GET /radar_data
  # GET /radar_data.json
  def index
    @radar_data = RadarDatum.all
  end

  # GET /radar_data/1
  # GET /radar_data/1.json
  def show
    @radar_datum = RadarDatum.find(params[:id])
    if @radar_datum.origin_lat == nil 	
    	@radar_datum.update_lat_lon 
    end 
  end

  # GET /radar_data/new
  def new
    @radar_datum = RadarDatum.new
  end

  # GET /radar_data/1/edit
  def edit
  end

  # GET /radar_data/1
  # GET /radar_data/1.json
  def download
     redirect_to @radar_datum.map_data.service_url(disposition: 'attachment')  	
  end

  # POST /radar_data
  # POST /radar_data.json
  def create
    @radar_datum = RadarDatum.new(radar_datum_params)

    respond_to do |format|
      if @radar_datum.save
        @radar_datum.update_lat_lon
        format.html { redirect_to @radar_datum, notice: 'Radar datum was successfully created.' }
        format.json { render :show, status: :created, location: @radar_datum }
      else
        format.html { render :new }
        format.json { render json: @radar_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /radar_data/1
  # PATCH/PUT /radar_data/1.json
  def update
    respond_to do |format|
      if @radar_datum.update(radar_datum_params)
        @radar_datum.update_lat_lon
        format.html { redirect_to @radar_datum, notice: 'Radar datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @radar_datum }
      else
        format.html { render :edit }
        format.json { render json: @radar_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /radar_data/1
  # DELETE /radar_data/1.json
  def destroy
    @radar_datum.destroy
    respond_to do |format|
      format.html { redirect_to radar_data_url, notice: 'Radar datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /radar_data/1.json
  def raw_json
    render :json => @radar_datum.map_data.download      
  end 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_radar_datum
      @radar_datum = RadarDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def radar_datum_params
      params.require(:radar_datum).permit(:id, :overlay_image, :map_data, :sampled_at, :origin_lat, :origin_lon, :header_metadata)
    end
end
