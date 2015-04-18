require 'test_helper'

class DatafetchControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
