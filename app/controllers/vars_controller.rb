class VarsController < ApplicationController

  # GET /vars
  # GET /vars.json
  def index
    @vars = Var.all
  end

  # GET /vars/1
  # GET /vars/1.json
  def show
    @var = Var.find(params[:id])
  end

  # GET /vars/new
  # GET /vars/new.1
  def new
    @var = Var.new
    @currentvars = Var.where(instrument_id: params[:inst_id])
    @instrument = Instrument.find(params[:inst_id])
  end

  # GET /vars/1/edit
  def edit
    @var = Var.find(params[:id])
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

  # PATCH/PUT /vars/1
  # PATCH/PUT /vars/1.json
  def update
    # Why do we have to do a find? E.g. SitesController.update() doesn't need to.
    @var = Var.find(params[:id])
    respond_to do |format|
      if @var.update(var_params)
        format.html { redirect_to @var, notice: 'Variable was successfully updated.' }
        format.json { render :show, status: :ok, location: @var }
      else
        format.html { render :edit }
        format.json { render json: @var.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vars/1
  # DELETE /vars/1.json
  def destroy
    # Why do we have to do a find? E.g. SitesController.update() doesn't need to.
    @var = Var.find(params[:id])
    @var.destroy
    respond_to do |format|
      format.html { redirect_to instruments_url, notice: 'Variable was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def var_params
    params.require(:var).permit(:name, :shortname, :instrument_id)
  end
  
end
