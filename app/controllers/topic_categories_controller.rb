class TopicCategoriesController < ApplicationController
  skip_authorize_resource only: [:index, :show]

  def index
    @topic_categories = TopicCategory.all
  end

  def show
  	@topic_category = TopicCategory.find(params[:id])
  end
end
