class TopicCategoriesController < ApplicationController

# GET /topic_categories
  def index
    @topic_categories = TopicCategory.all
  end

  def show
  	@topic_category = TopicCategory.find(params[:id])
  end


end
