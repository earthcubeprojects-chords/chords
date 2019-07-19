class InfluxdbTagsController < ApplicationController
  load_and_authorize_resource

  def index
    @influxdb_tags = @influxdb_tags.sort_by{|x| [x.instrument.site.name, x.instrument.name, x.name]}
  end

  def show
  end

  def new
  end

  def create
    @influxdb_tag = InfluxdbTag.new(influxdb_tag_params)

    respond_to do |format|
      if @influxdb_tag.save
        format.html { redirect_to influxdb_tags_path, notice: 'InfluxDB Tag created' }
        format.json { render :show, status: :created, location: @influxdb_tag }
      else
        format.html { render :new }
        format.json { render json: @influxdb_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @influxdb_tag.update(influxdb_tag_params)
        format.html { redirect_to @influxdb_tag, notice: 'Influxdb tag was successfully updated.' }
        format.json { render :show, status: :ok, location: @influxdb_tag }
      else
        format.html { render :show }
        format.json { render json: @influxdb_tag.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @influxdb_tag.destroy
        format.html { redirect_to influxdb_tags_path, notice: 'Influxdb tag was successfully destroyed' }
        format.json { head :no_content, status: :ok }
      else
        format.html { redirect_to influxdb_tag_path(@influxdb_tag), alert: 'Influxdb tag could not be destroyed' }
        format.json { render json: '{"errors": ["Influxdb tag could not be destroyed"]}', status: :bad_request }
      end
    end
  end

private
  # Never trust parameters from the scary internet, only allow the white list through.
  def influxdb_tag_params
    params.fetch(:influxdb_tag, {})
    params.require(:influxdb_tag).permit(:name, :value, :instrument_id)
  end
end
