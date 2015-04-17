require 'test_helper'

class ConfigureControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
