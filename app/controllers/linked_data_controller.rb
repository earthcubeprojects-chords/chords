class LinkedDataController < ApplicationController
  authorize_resource

  def index
    @linked_datum = LinkedDatum.first

    if @linked_datum.nil?
      LinkedDatum.initialize(root_url)
      @linked_datum = LinkedDatum.first
    end

    respond_to do |format|
      format.html
      format.json { render json: @linked_datum.to_json_ld }
    end
  end

  def show
    redirect_to linked_data_path
  end

  def create
  end

  def edit
    @linked_datum = LinkedDatum.first
  end

  def update
    @linked_datum = LinkedDatum.first

    respond_to do |format|
      if @linked_datum.update(linked_datum_params)
        format.html { redirect_to linked_datum_path, notice: 'JSON-LD information was successfully updated' }
      else
        format.html { render :edit }
      end
    end
  end

private
  def linked_datum_params
    params.require(:linked_datum).permit(:name, :description, :keywords, :license, :doi)
  end
end
