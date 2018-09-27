class VarsController < ApplicationController
  include ArchiveHelper

  load_and_authorize_resource except: :get_autocomplete_items

  autocomplete :measured_property, :label, :full => true
  autocomplete :unit, :name, :full => true

  def index
  end

  def show
  end

  def new
    @instrument = Instrument.find(params[:instrument_id])
    @return = params[:return]
  end

  def edit
    @return = params[:return]
  end

  def create
    respond_to do |format|
      if @var.save
        format.html { redirect_to Instrument.find(@var.instrument_id), notice: 'Variable was successfully created' }
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
        format.html { redirect_to @var, notice: 'Var was successfully updated' }
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

  def get_autocomplete_items (parameters)
    authorize! :read, Var

    if(params[:search_mode].eql? 'unit_source')
      items = Unit.where("source = :source and name LIKE :term", {source: Profile.first.unit_source, term: '%' + params[:term] + '%'})
    elsif(params[:search_mode].eql? 'measured_property_source')
      items = MeasuredProperty.where("source = :source and name LIKE :term", {source: Profile.first.measured_property_source, term: '%' + params[:term] + '%'})
    else
      items = super(parameters)
    end
  end

private
  def var_params
    params.require(:var).permit(:name, :shortname, :instrument_id, :units, :measured_property_id, :minimum_plot_value, :maximum_plot_value, :unit_id, :general_category, :return)
  end
end
