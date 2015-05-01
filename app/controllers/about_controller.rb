class AboutController < ApplicationController
  def index
    @profile = Profile.first
  end
end
