require 'test_helper'

class DeviceControllerTest < ActionController::TestCase
  test "should get disable" do
    get :disable
    assert_response :success
  end

  test "should get enable" do
    get :enable
    assert_response :success
  end

end
