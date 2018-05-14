class SiteTypesController < ApplicationController
  skip_authorize_resource only: [:index, :show]

	def index
    @site_types = SiteType.all
  end

  def show
  	@site_type = SiteType.find(params[:id])
  end
end
