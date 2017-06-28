class UnitsController < ApplicationController


  def index
    @units = Unit.all
  end

  def show
  	@unit = Unit.find(params[:id])
  end

	private
    def unit_params
      params.require(:unit).permit(:name, :abbreviation)
    end

end
