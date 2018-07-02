class ArchiveJobsController < ApplicationController
  load_and_authorize_resource except: :delete_completed_jobs

  def delete_completed_jobs
    authorize! :destroy, ArchiveJob

    ArchiveJob.where(:status => 'success').destroy_all

    flash[:notice] = "All successful archive jobs have been removed."

    redirect_to archive_jobs_path
  end

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

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

  def update
    respond_to do |format|
      if @archive_job.update(archive_job_params)
        format.html { redirect_to @archive_job, notice: 'Archive job was successfully updated.' }
        format.json { render :show, status: :ok, location: @archive_job }
      else
        format.html { render :edit, alert: 'Could not update archive job' }
        format.json { render json: @archive_job.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @archive_job.destroy
        format.html { redirect_to archive_jobs_url, notice: 'Archive job was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { render :show, alert: 'Could not destroy archive job' }
        format.json { render json: @archive_job.errors, status: :bad_request }
      end
    end
  end

private

  def archive_job_params
    params.require(:archive_job).permit(:archive_name, :start_at, :end_at, :status, :message)
  end
end
