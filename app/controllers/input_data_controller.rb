require 'securerandom'
class InputDataController < ApplicationController
  before_action :set_input_datum, only: [:download, :netcdf, :show, :edit, :update, :destroy]

  # GET /input_data
  # GET /input_data.json
  def index
    @input_data = InputDatum.all
  end

  # GET /input_data/1
  # GET /input_data/1.json
  def show
      @input_datum = InputDatum.find(params[:id])
  end

  # GET /input_data/new
  def new
    @input_datum = InputDatum.new
  end

  # GET /input_data/1/edit
  def edit
  end

  # GET /input_data/1
  # GET /input_data/1.nc
  def download
    redirect_to @input_datum.input_netcdf.service_url(disposition: 'attachment')
  end

  # POST /input_data
  # POST /input_data.json
  def create
    @input_datum = InputDatum.new(input_datum_params)
    
    respond_to do |format|
      if @input_datum.save
        if @input_datum.input_netcdf.attached?
          @input_datum.convert_netcdf_to_plot_file
        end
        format.html { redirect_to @input_datum, notice: 'Input datum was successfully created.' }
        format.json { render :show, status: :created, location: @input_datum }
      else
        format.html { render :new }
        format.json { render json: @input_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /input_data/1
  # PATCH/PUT /input_data/1.json
  def update
    respond_to do |format|
      if @input_datum.update(input_datum_params)
        if @input_datum.input_netcdf.attached?
           @input_datum.convert_netcdf_to_plot_file
        end
        format.html { redirect_to @input_datum, notice: 'Input datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @input_datum }
      else
        format.html { render :edit }
        format.json { render json: @input_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /input_data/1
  # DELETE /input_data/1.json
  def destroy
    @input_datum.destroy
    respond_to do |format|
      format.html { redirect_to input_data_url, notice: 'Input datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

#GET /input_data/1.nc

def netcdf
        render :nc => @input_datum.input_netcdf.download
end

#test of running python script
def home
    #our_input_text = " heart"
    #@heart = `python lib/assets/python/heart.py "#{our_input_text}"`

    #create a temp file with random name
    # temp_file_name = SecureRandom.uuid + '.netcdf'
    # @image_file = SecureRandom.uuid
    # full_image_path = @image_file + "cartesian_gridded_zh.png"
    # @temp_file_path = "/Users/suresha/databaseVersionApp/app/controllers/#{temp_file_name}"

    # #get controller object
    
    input_data_id = 1

    input_data_object = InputDatum.find(input_data_id)

    #call method to run python script 
    input_data_object.convert_netcdf_to_plot_file()

    # data = input_data_object.input_netcdf.download
    #download file and save it to the temp file created above

   #file write data  
    # File.open(@temp_file_path, "wb"){|file| file.write data}

    #call the python script that converts an input netcdf data
    #to a PNG plot
    # @python_output = `python /Users/suresha/databaseVersionApp/lib/assets/python/make_and_plot_grid.py #{@temp_file_path} #{full_image_path}`

    # #attach output plot file 
    # input_data_object.plot_file.attach(io: File.open(full_image_path), filename: "File.basename(full_image_path)", content_type: "image/png")

    # #delete full image path and temp file
    # File.delete(@temp_file_path)
    # File.delete(full_image_path) 
end


  def imageOverlay 
    	
  end 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_input_datum
      @input_datum = InputDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def input_datum_params
      params.require(:input_datum).permit(:id, :input_netcdf, :name, :origin_lat, :origin_lon, :scanned_at, :header_metadata)
    end
end
