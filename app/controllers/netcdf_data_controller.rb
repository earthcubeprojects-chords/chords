class NetcdfDataController < ApplicationController
  before_action :set_netcdf_datum, only: [:show, :edit, :update, :destroy]

  # GET /netcdf_data
  # GET /netcdf_data.json
  def index
    @netcdf_data = NetcdfDatum.all
  end

  # GET /netcdf_data/1
  # GET /netcdf_data/1.json
  def show
  end

  # GET /netcdf_data/new
  def new
    @netcdf_datum = NetcdfDatum.new
  end

  # GET /netcdf_data/1/edit
  def edit
  end

  # POST /netcdf_data
  # POST /netcdf_data.json
  def create
    @netcdf_datum = NetcdfDatum.new(netcdf_datum_params)

    respond_to do |format|
      if @netcdf_datum.save
        format.html { redirect_to @netcdf_datum, notice: 'Netcdf datum was successfully created.' }
        format.json { render :show, status: :created, location: @netcdf_datum }
      else
        format.html { render :new }
        format.json { render json: @netcdf_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /netcdf_data/1
  # PATCH/PUT /netcdf_data/1.json
  def update
    respond_to do |format|
      if @netcdf_datum.update(netcdf_datum_params)
        format.html { redirect_to @netcdf_datum, notice: 'Netcdf datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @netcdf_datum }
      else
        format.html { render :edit }
        format.json { render json: @netcdf_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /netcdf_data/1
  # DELETE /netcdf_data/1.json
  def destroy
    @netcdf_datum.destroy
    respond_to do |format|
      format.html { redirect_to netcdf_data_url, notice: 'Netcdf datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_netcdf_datum
      @netcdf_datum = NetcdfDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def netcdf_datum_params
      params.fetch(:netcdf_datum, {})
    end
end
