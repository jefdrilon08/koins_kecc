require "test_helper"

class ApiReceiveMembersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_receive_members_index_url
    assert_response :success
  end

  test "should get show" do
    get api_receive_members_show_url
    assert_response :success
  end
end
