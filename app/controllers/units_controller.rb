class UnitsController < ApplicationController


  def index
    @units = Unit.all
  end

  def show
  	@unit = Unit.find(params[:id])
  end

  def get_autocomplete_items(parameters)
    p = Profile.first
    super(parameters).where(:unit_source => p.unit_source)
  end

	private
    def unit_params
      params.require(:unit).permit(:name, :abbreviation)
    end

end
