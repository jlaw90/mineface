require 'test_helper'

class PoolControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get update" do
    get :update
    assert_response :success
  end

  test "should get delete" do
    get :delete
    assert_response :success
  end

  test "should get enable" do
    get :enable
    assert_response :success
  end

  test "should get disable" do
    get :disable
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

end
