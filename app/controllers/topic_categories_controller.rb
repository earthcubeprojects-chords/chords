class TopicCategoriesController < ApplicationController

# GET /topic_categories
  def index
    @topic_categories = TopicCategory.all
  end

end
