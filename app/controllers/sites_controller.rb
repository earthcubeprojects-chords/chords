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

  # TODO: Clean this up and consider changing to another map framework
  def geo
    authorize! :read, Site

    @sites = Site.accessible_by(current_ability)

    # The marker generation really should be done in the page javascript, so that
    # the marker can be dynamcally manipulated on the client side.
    @site_markers = Gmaps4rails.build_markers(@sites) do |site, marker|
      # Create site link
      site_html = ""
      site_html += ActionController::Base.helpers.content_tag(:h4,
        (ActionController::Base.helpers.link_to(site.name ||= 'Name?',site_path(site))).html_safe).html_safe

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
        ActionController::Base.helpers.content_tag(:th, 'Instruments').html_safe
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
end
