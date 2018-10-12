class UnitsController < ApplicationController
  load_and_authorize_resource

  def index
    @data = {}
    @sources = @units.where('source IS NOT NULL').map{|unit| unit.source}.uniq.sort_by{|source| source.downcase}
    @unit_types = @units.where('unit_type IS NOT NULL').map{|unit| unit.unit_type}.uniq.sort_by{|type| type.downcase}

    @sources.each do |source|
      @data[source] = {}
    end

    @units.each do |unit|
      @data[unit.source] = {} if !@data.keys.include?(unit.source)
      @data[unit.source][unit.unit_type] = [] if !@data[unit.source].keys.include?(unit.unit_type)
      @data[unit.source][unit.unit_type] << {name: unit.name, abbreviation: unit.abbreviation}
    end
  end

  def show
  end

private
  def unit_params
    params.require(:unit).permit(:name, :abbreviation)
  end
end
