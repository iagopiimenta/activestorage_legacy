require "test_helper"
require "database/setup"

class ActiveStorage::VariantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @blob = create_image_blob filename: "racecar.jpg"
  end

  test "showing variant inline" do
    get rails_blob_variation_url(
      filename: @blob.filename,
      signed_blob_id: @blob.signed_id,
      variation_key: ActiveStorage::Variation.encode(resize: "100x100"))

    assert_match /racecar\.jpg\?.*disposition=inline/, @response.redirect_url

    image = read_image_variant(@blob.variant(resize: "100x100"))
    assert_equal 100, image.width
    assert_equal 67, image.height
  end
end
