class VarsController < ApplicationController
  before_action :authenticate_user!
  
  before_action :set_var, only: [:show, :edit, :update, :destroy]

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
  def new
    @var = Var.new
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
        format.html { redirect_to Instrument.find(@var.instrument_id), notice: 'Variable was successfully created.' }
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
    respond_to do |format|
      if @var.update(var_params)
        format.html { redirect_to @var, notice: 'Var was successfully updated.' }
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
    @var.destroy
    
    respond_to do |format|
      format.html { redirect_to Instrument.find(@var.instrument_id), notice: 'Variable was deleted.' }      
      # format.html { redirect_to vars_url, notice: 'Var was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_var
      @var = Var.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def var_params
      params.require(:var).permit(:name, :shortname, :instrument_id)
    end
end
