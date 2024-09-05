require "test_helper"

class GroceryListControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get grocery_list_index_url
    assert_response :success
  end
end
