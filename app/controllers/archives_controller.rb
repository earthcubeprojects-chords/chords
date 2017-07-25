class ArchivesController < ApplicationController

  # GET /archives

  def index
    authorize! :manage, Archive
    
    if @archive == nil
      Archive.initialize
      @archive = Archive.first
    end

  end



  # PATCH/PUT /archives/1
  def create
    authorize! :manage, Archive
  
    # update attributes
    if !@archive.update(archive_params)
      if (! @archive.valid?)
        flash.now[:alert] = @archive.errors.full_messages.to_sentence
      end

      render :index
      return
    end

      
    flash[:notice] = 'Archive configuration saved.'
    
    redirect_to archives_path
  end
  


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archive
      @archive = Archive.first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def archive_params
      # params.fetch(:archive, {:name ,:base_url, :send_frequency, :last_archived_at})
      
      params.require(:archive).permit(
        :name ,:base_url, :send_frequency, :last_archived_at
        )
    end
end


