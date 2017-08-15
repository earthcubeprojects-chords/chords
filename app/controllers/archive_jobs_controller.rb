class ArchiveJobsController < ApplicationController
  before_action :set_archive_job, only: [:show, :edit, :update, :destroy]



  def delete_completed_jobs    
    ArchiveJob.where(:status => 'success').destroy_all
    
    flash[:notice] = "All successful archive jobs have been removed."
    
    redirect_to archive_jobs_path  
  end

  # GET /archive_jobs
  # GET /archive_jobs.json
  def index
    @archive_jobs = ArchiveJob.all
  end

  # GET /archive_jobs/1
  # GET /archive_jobs/1.json
  def show
  end

  # GET /archive_jobs/new
  def new
    @archive_job = ArchiveJob.new
  end

  # GET /archive_jobs/1/edit
  def edit
  end

  # POST /archive_jobs
  # POST /archive_jobs.json
  def create
    @archive_job = ArchiveJob.new(archive_job_params)

    respond_to do |format|
      if @archive_job.save
        format.html { redirect_to @archive_job, notice: 'Archive job was successfully created.' }
        format.json { render :show, status: :created, location: @archive_job }
      else
        format.html { render :new }
        format.json { render json: @archive_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /archive_jobs/1
  # PATCH/PUT /archive_jobs/1.json
  def update
    respond_to do |format|
      if @archive_job.update(archive_job_params)
        format.html { redirect_to @archive_job, notice: 'Archive job was successfully updated.' }
        format.json { render :show, status: :ok, location: @archive_job }
      else
        format.html { render :edit }
        format.json { render json: @archive_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /archive_jobs/1
  # DELETE /archive_jobs/1.json
  def destroy
    @archive_job.destroy
    respond_to do |format|
      format.html { redirect_to archive_jobs_url, notice: 'Archive job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive_job
      @archive_job = ArchiveJob.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def archive_job_params
      params.require(:archive_job).permit(:archive_name, :start_at, :end_at, :status, :message)
    end
end
