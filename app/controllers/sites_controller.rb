class SitesController < ApplicationController
  load_and_authorize_resource

  def index
    @instruments = Instrument.accessible_by(current_ability)
  end

  def show
    @instruments = @site.instruments.accessible_by(current_ability)
  end

  def new
  end

  def edit
  end

  def map
  end

  ## generates json for all sites:
  # (status is true if all instruments at the site are active and have recent data.
  #  We should have a more descriptive key than "status" for this.)
  # {
  # "type": "FeatureCollection",
  # "features": [
  #   {
  #     "type": "Feature",
  #     "geometry": {
  #       "type": "Point",
  #       "coordinates": [
  #         "-105.245923",
  #         "39.971957"
  #       ]
  #     },
  #     "properties": {
  #       "name": "Test Site",
  #       "url": "example.chordsrt.com/sites/1",
  #       "status": true
  #     }
  #   }
  # ]
  # }
  def map_markers_geojson
    features = []

    json_data = @sites.each do |site|
      # Are there any instruments at this site which are active and missing data?
      missing_recent_data = (site.instruments.select{|i| ((i.is_receiving_data == false) && (i.is_active == true))}.length == 0)
      # Only consider sites with active instruments
      if (site.instruments.select{|i| i.is_active == true}.length > 0)
        geometry = {type: "Point", coordinates: [site.lon, site.lat]}
        properties = {name: site.name, url: site_url(site), status: missing_recent_data}

        feature = {type: "Feature", geometry: geometry, properties: properties}
        features << feature
      end
    end
    logger.debug "*** map_markers_geojson features: #{features}"

    sites_geojson = {type: "FeatureCollection", features: features}.to_json

    render json: sites_geojson
  end

  ## generate json for particular site's active instruments
  # (status is true if the instrument is active and has recent data.
  #  We should have a more descriptive key than "status" for this.)
  # [
  #  {
  #    "name": "Instrument 1", 
  #    "status": true, 
  #    "url": "asdfasdf"
  #   }, 
  #   {
  #     "name": "Instrument 2", 
  #     "status": true, 
  #     "url": "asdfasdf"
  #   }
  # ]
  # .
  def map_balloon_json
    instrument_json = []

    @site.instruments.each do |instrument|
      inst = {name: instrument.name, status: instrument.is_receiving_data, url: instrument_url(instrument)}
      if instrument.is_active
        instrument_json << inst
      end
    end

    render json: instrument_json.to_json
  end

  def create
    respond_to do |format|
      if @site.save
        format.html { redirect_to '/sites', notice: 'Site was successfully created.' }
        format.json { render :show, status: :created, location: @site }
      else
        format.html { render :new }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @site.update(site_params)
        format.html { redirect_to @site, notice: 'Site was successfully updated.' }
        format.json { render :show, status: :ok, location: @site }
      else
        format.html { render :edit }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @site.destroy
        format.html { redirect_to sites_url, notice: 'Site was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { render :show, alert: 'Site could not be destroyed' }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

private
  def site_params
    params.require(:site).permit(:name, :lat, :lon, :elevation, :description, :site_type_id)
  end
end
