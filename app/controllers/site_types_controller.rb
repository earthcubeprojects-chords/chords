class SiteTypesController < ApplicationController

	def index
    @site_types = SiteType.all
  end

  def show
  	@site_type = SiteType.find(params[:id])
  end
end
