require 'test_helper'

class AllAssetsSslTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should not have http on the homepage" do
    https!
    get("/")
    assert_response :success
    assert_select("img[src=^https]", :minimum => 1)
    assert_select("img[src=^http]", :count => 0)
  end
end
