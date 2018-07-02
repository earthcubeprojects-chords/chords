class MeasuredPropertiesController < ApplicationController
  load_and_authorize_resource

  def index
    @measured_properties = MeasuredProperty.all
  end

  def show
  end

  def new
    @measured_property = MeasuredProperty.new
  end

  def create
    @measured_property = MeasuredProperty.new(measured_property_params)

    respond_to do |format|
      if @measured_property.save
        format.html { redirect_to @measured_property, notice: 'Measured property was successfully created.' }
        format.json { render :show, status: :created, location: @measured_property }
      else
        format.html { render :new }
        format.json { render json: @measured_property.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @measured_property.update(measured_property_params)
        format.html { redirect_to @measured_property, notice: 'Measured property was successfully updated.' }
        format.json { render :show, status: :ok, location: @measured_property }
      else
        format.html { render :edit }
        format.json { render json: @measured_property.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @measured_property.destroy

    respond_to do |format|
      format.html { redirect_to measured_properties_url, notice: 'Measured property was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # def get_autocomplete_items(parameters)
  #   p = Profile.first
  #   super(parameters).where(:measured_property_source => p.measured_property_source)
  # end

private
  def measured_property_params
    params.require(:measured_property).permit(:name, :label, :url, :definition)
  end
end
