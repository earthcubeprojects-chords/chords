require 'test_helper'

class MeasuredPropertiesControllerTest < ActionController::TestCase
  setup do
    @measured_property = measured_properties(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:measured_properties)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create measured_property" do
    assert_difference('MeasuredProperty.count') do
      post :create, measured_property: { definition: @measured_property.definition, label: @measured_property.label, name: @measured_property.name, url: @measured_property.url }
    end

    assert_redirected_to measured_property_path(assigns(:measured_property))
  end

  test "should show measured_property" do
    get :show, id: @measured_property
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @measured_property
    assert_response :success
  end

  test "should update measured_property" do
    patch :update, id: @measured_property, measured_property: { definition: @measured_property.definition, label: @measured_property.label, name: @measured_property.name, url: @measured_property.url }
    assert_redirected_to measured_property_path(assigns(:measured_property))
  end

  test "should destroy measured_property" do
    assert_difference('MeasuredProperty.count', -1) do
      delete :destroy, id: @measured_property
    end

    assert_redirected_to measured_properties_path
  end
end
