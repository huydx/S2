require 'test_helper'

class StreamingControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
