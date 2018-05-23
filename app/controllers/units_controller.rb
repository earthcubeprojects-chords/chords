class UnitsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def show
  end

private
  def unit_params
    params.require(:unit).permit(:name, :abbreviation)
  end
end
