class MeasuredPropertiesController < ApplicationController
  before_action :set_measured_property, only: [:show, :edit, :update, :destroy]


  # def get_autocomplete_items(parameters)
  #   p = Profile.first
  #   super(parameters).where(:measured_property_source => p.measured_property_source)
  # end


  # GET /measured_properties
  # GET /measured_properties.json
  def index
    @measured_properties = MeasuredProperty.all
  end

  # GET /measured_properties/1
  # GET /measured_properties/1.json
  def show
  end

  # GET /measured_properties/new
  def new
    @measured_property = MeasuredProperty.new
  end

  # GET /measured_properties/1/edit
  def edit
  end

  # POST /measured_properties
  # POST /measured_properties.json
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

  # PATCH/PUT /measured_properties/1
  # PATCH/PUT /measured_properties/1.json
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

  # DELETE /measured_properties/1
  # DELETE /measured_properties/1.json
  def destroy
    @measured_property.destroy
    respond_to do |format|
      format.html { redirect_to measured_properties_url, notice: 'Measured property was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_measured_property
      @measured_property = MeasuredProperty.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def measured_property_params
      params.require(:measured_property).permit(:name, :label, :url, :definition)
    end
end
