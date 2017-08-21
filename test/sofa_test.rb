require 'test_helper'

class Sofa::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Sofa
  end

  test "include here" do
    get "/admin/here.js", xhr: true

    assert_equal "text/javascript", @response.content_type
  end
end
