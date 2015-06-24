class VarsController < ApplicationController

  # GET /vars
  # GET /vars.json
  def index
    @vars = Var.all
  end

  # GET /vars/1
  # GET /vars/1.json
  def show
  end

  # GET /vars/new
  # GET /vars/new.1
  def new
    @var = Var.new
    @instrument = Instrument.find(params[:inst_id])
  end

  # GET /vars/1/edit
  def edit
  end
  
  # POST /vars
  # POST /vars.json
  def create
    @var = Var.new(var_params)

    respond_to do |format|
      if @var.save
        format.html { redirect_to @var, notice: 'Variable was successfully created.' }
        format.json { render :show, status: :created, location: @var }
      else
        format.html { render :new }
        format.json { render json: @var.errors, status: :unprocessable_entity }
      end
    end
  end

  def var_params
    params.require(:var).permit(:name, :shortname, :instrument_id)
  end
  
end
