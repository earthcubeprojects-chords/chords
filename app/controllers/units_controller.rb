class UnitsController < ApplicationController
  def index
    @units = Unit.all
  end

  def show
  	@unit = Unit.find(params[:id])
  end

end
