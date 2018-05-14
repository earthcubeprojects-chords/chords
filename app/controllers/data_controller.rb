class DataController < ApplicationController
  def index
    authorize! :view, :data

    @sites = Site.accessible_by(current_ability)
    @instruments = Instrument.accessible_by(current_ability)
    @db_expiry_time = ApplicationHelper.db_expiry_time
  end
end
