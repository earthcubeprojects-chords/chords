class DataController < ApplicationController
  load_and_authorize_resource

  def index
    @sites = Site.accessible_by(current_ability)
    @instruments = Instrument.accessible_by(current_ability)
    @db_expiry_time = ApplicationHelper.db_expiry_time
  end

  def create
  end
end
