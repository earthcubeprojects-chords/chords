class VarsController < ApplicationController
  load_and_authorize_resource except: :get_autocomplete_items

  def index
  end

  def show
  end

  def new
    @instrument = Instrument.find(params[:instrument_id])
    @return = params[:return]

    @units = get_units
    @measured_properties = get_measured_properties
  end

  def edit
    @instrument = @var.instrument
    @return = params[:return]

    @units = get_units
    @measured_properties = get_measured_properties
  end

  def create
    respond_to do |format|
      if @var.save
        format.html { redirect_to instrument_path(@var.instrument), notice: 'Variable was successfully created' }
        format.json { render :show, status: :created, location: @var }
      else
        format.html { render :new }
        format.json { render json: @var.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @var.update(var_params)
        format.html { redirect_to instrument_path(@var.instrument), notice: 'Variable was successfully updated' }
        format.json { render :show, status: :ok, location: @var }
      else
        format.html { render :edit }
        format.json { render json: @var.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    instrument = @var.instrument

    respond_to do |format|
      if @var.destroy
        if instrument
          format.html { redirect_to instrument, notice: 'Variable was deleted' }
        else
          format.html { redirect_to vars_path, notice: 'Variable was deleted' }
        end

        format.json { head :no_content, status: :success }
      else
        format.html { render :show, alert: 'Could not destroy variable' }
        format.json { render json: @var.errors, status: :unprocessable_entity }
      end
    end
  end

private
  def var_params
    params.require(:var).permit(:name, :shortname, :instrument_id, :measured_property_id, :minimum_plot_value, :maximum_plot_value, :unit_id, :general_category, :return)
  end

  def get_units
    Unit.where(source: Profile.first.unit_source).order(:name)
  end

  def get_measured_properties
    MeasuredProperty.where(source: Profile.first.measured_property_source).order(:label)
  end
end
