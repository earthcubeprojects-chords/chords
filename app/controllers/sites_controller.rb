class SitesController < ApplicationController
  
  before_action :set_site, only: [:show, :edit, :update, :destroy]

  # GET /sites
  # GET /sites.json
  def index
    authorize! :view, Site

    @sites = Site.all
    @instruments = Instrument.all
    @google_maps_key = Profile.first.google_maps_key
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
    authorize! :view, Site

    @instruments = Instrument.all.where("site_id = ?", params[:id])
    @site = Site.find(params[:id])
  end

  # GET /sites/new
  def new
    authorize! :manage, Site

    @site = Site.new
    
  end

  # GET /sites/1/edit
  def edit
    authorize! :manage, Site
  end
  
  # GET /sites/geo
  def geo
    authorize! :view, Site

    @sites = Site.all
    
    # The marker generation really should be done in the page javascript, so that 
    # the marker can be dynamcally manipulated on the client side.
    @site_markers = Gmaps4rails.build_markers(@sites) do |site, marker|
      # Create site link
      site_html = ""
      site_html += ActionController::Base.helpers.content_tag(:p, 
        ('Site:' + ActionController::Base.helpers.link_to(site.name ||= 'Name?',site_path(site))).html_safe).html_safe

      # Collect a status image and link for each instrument at this site
      status_and_links = site.instruments.collect do |inst|
        image_html = inst.is_receiving_data ? 
          ActionController::Base.helpers.image_tag('button_green_50.png', :size =>'16') : ActionController::Base.helpers.image_tag('button_red_50.png', :size =>'16')
        [image_html.html_safe, ActionController::Base.helpers.link_to(inst.name, instrument_path(inst)).html_safe] 
      end
      
      # Build instrument table
      # Instrument status display is commented out since it does not dynamically update.
      rows_html = ""
      rows_html += ActionController::Base.helpers.content_tag(:tr,
      #  ActionController::Base.helpers.content_tag(:th, 'Status', :style =>"padding-right:10px;").html_safe +
        ActionController::Base.helpers.content_tag(:th, 'Instrument').html_safe
      ).html_safe
      status_and_links.each do |x|
        rows_html += ActionController::Base.helpers.content_tag(:tr,
        #   ActionController::Base.helpers.content_tag(:td, x[0]).html_safe +
          ActionController::Base.helpers.content_tag(:td, x[1]).html_safe
         ).html_safe
      end
      inst_table_html = ActionController::Base.helpers.content_tag(:table, rows_html.html_safe).html_safe
      
      info_window_html = site_html + inst_table_html

      marker.infowindow(info_window_html)
      marker.lat site.lat
      marker.lng site.lon
      marker.title site.name
    end
  end
  
  # POST /sites
  # POST /sites.json
  def create
    authorize! :manage, Site
    
    @site = Site.new(site_params)
    
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

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    authorize! :manage, Site
            
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

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    authorize! :manage, Site
        
    @site.destroy
    respond_to do |format|
      format.html { redirect_to sites_url, notice: 'Site was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site
      @site = Site.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def site_params
      params.require(:site).permit(:name, :lat, :lon, :elevation, :description, :site_type_id, :cuahsi_site_code)
    end
end
