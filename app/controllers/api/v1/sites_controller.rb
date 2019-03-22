module API
  module V1
    class SitesController < ApplicationController
      authorize_resource
      respond_to :json

      def index
        @sites = Site.accessible_by(current_ability)

        render json: @sites, status: :ok
      end

      def show
        @site = Site.accessible_by(current_ability).where(id: params[:id]).first

        if @site
          render json: @site, status: :ok
        else
          render json: { errors: ['Site not found.'] }, status: :not_found
        end
      end

      def create
      end

      def update
      end

      def destroy
        @site = Site.accessible_by(current_ability).where(id: params[:id]).first

        if @site
          if @site.destroy
            head :no_content, status: :no_content
          else
            render json: @site.errors, status: :unprocessable_entity
          end
        else
          render json: { errors: ['Site not found.'] }, status: :not_found
        end
      end

    private
      def site_params
        params.require(:site).permit(:name, :lat, :lon, :elevation, :description, :site_type_id, :cuahsi_site_code)
      end
    end
  end
end
