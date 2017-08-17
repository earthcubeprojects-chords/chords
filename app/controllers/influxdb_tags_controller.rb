class InfluxdbTagsController < ApplicationController
  before_action :set_influxdb_tag, only: [:show, :edit, :update, :destroy]

  # GET /influxdb_tags
  # GET /influxdb_tags.json
  def index
    @influxdb_tags = InfluxdbTag.all
  end

  # GET /influxdb_tags/1
  # GET /influxdb_tags/1.json
  def show
  end

  # GET /influxdb_tags/new
  def new
    authorize! :manage, Instrument

    @influxdb_tag = InfluxdbTag.new
  end

  # GET /influxdb_tags/1/edit
  def edit
    authorize! :manage, Instrument
  end

  # POST /influxdb_tags
  # POST /influxdb_tags.json
  def create
    authorize! :manage, Instrument
    
    @influxdb_tag = InfluxdbTag.new(influxdb_tag_params)

    respond_to do |format|
      if @influxdb_tag.save
        format.html { redirect_to Instrument.find(@influxdb_tag.instrument_id), notice: 'InfluxDB Tag created.' }
        # format.html { redirect_to @influxdb_tag, notice: 'Influxdb tag was successfully created.' }
        format.json { render :show, status: :created, location: @influxdb_tag }
      else
        format.html { render :new }
        format.json { render json: @influxdb_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /influxdb_tags/1
  # PATCH/PUT /influxdb_tags/1.json
  def update
    authorize! :manage, Instrument

    respond_to do |format|
      if @influxdb_tag.update(influxdb_tag_params)
        format.html { redirect_to @influxdb_tag, notice: 'Influxdb tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @influxdb_tag }
      else
        format.html { render :edit }
        format.json { render json: @influxdb_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /influxdb_tags/1
  # DELETE /influxdb_tags/1.json
  def destroy
    authorize! :manage, Instrument
    
    @influxdb_tag.destroy
    respond_to do |format|
      # format.html { redirect_to influxdb_tags_url, notice: 'Influxdb tag was successfully destroyed.' }
      format.html { redirect_to Instrument.find(@influxdb_tag.instrument_id), notice: 'Influxdb tag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_influxdb_tag
      @influxdb_tag = InfluxdbTag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def influxdb_tag_params
      params.fetch(:influxdb_tag, {})
      params.require(:influxdb_tag).permit(:name, :value, :instrument_id)

    end
end
