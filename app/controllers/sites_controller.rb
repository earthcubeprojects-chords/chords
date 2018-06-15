class SitesController < ApplicationController
  load_and_authorize_resource

  def index
    @instruments = Instrument.accessible_by(current_ability)
    @google_maps_key = Profile.first.google_maps_key
  end

  def show
    @instruments = @site.instruments.accessible_by(current_ability)
  end

  def new
  end

  def edit
  end

  def geo
  end

  def geo_json
    render json: sites_geojson
  end

  def create
    if Archive.first.name == 'CUAHSI'
      @site.cuahsi_site_code = @site.get_cuahsi_sitecode
    end

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
    params.require(:site).permit(:name, :lat, :lon, :elevation, :description, :site_type_id, :cuahsi_site_code)
  end

  def sites_geojson
    # loop through all sites
    features = []
    json_data = @sites.each do |site|
      # determine whether site is active (ie. all instruments are active)
      activeBool = (site.instruments.where({is_active: false}).length == 0)

      # loop through all instruments of particular site
      siteInst = []
      site.instruments.each do |instrument|
        inst = {name: instrument.name, active: instrument.is_active, url: instrument.instrument_url}
        siteInst.push(inst)
      end

      geometry = {type: "Point", coordinates: [site.lon, site.lat]}
      properties = {name: site.name, url: site.site_url, active: activeBool, instruments: siteInst}

      feature = {type: "Feature", geometry: geometry, properties: properties}
      features.push(feature)
    end

    {type: "FeatureCollection", features: features}.to_json
  end
end
