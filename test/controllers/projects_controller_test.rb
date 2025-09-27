require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "should get select_role" do
    get projects_select_role_url
    assert_response :success
  end
end
