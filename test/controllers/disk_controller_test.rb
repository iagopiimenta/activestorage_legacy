require "test_helper"
require "database/setup"

class ActiveStorage::DiskControllerTest < ActionDispatch::IntegrationTest
  test "showing blob inline" do
    blob = create_blob

    get blob.service_url
    assert_equal "inline; filename=\"#{blob.filename.base}\"", @response.headers["Content-Disposition"]
    assert_equal "text/plain", @response.headers["Content-Type"]
  end

  test "showing blob as attachment" do
    blob = create_blob

    get blob.service_url(disposition: :attachment)
    assert_equal "attachment; filename=\"#{blob.filename.base}\"", @response.headers["Content-Disposition"]
    assert_equal "text/plain", @response.headers["Content-Type"]
  end


  test "directly uploading blob with integrity" do
    data = "Something else entirely!"
    blob = create_blob_before_direct_upload byte_size: data.size, checksum: Digest::MD5.base64digest(data)

    put blob.service_url_for_direct_upload, data, { 'CONTENT_TYPE' => "text/plain" }
    assert_response :no_content
    assert_equal data, blob.download
  end

  test "directly uploading blob without integrity" do
    data = "Something else entirely!"
    blob = create_blob_before_direct_upload byte_size: data.size, checksum: Digest::MD5.base64digest("bad data")

    put blob.service_url_for_direct_upload, data
    assert_response :unprocessable_entity
    assert_not blob.service.exist?(blob.key)
  end

  test "directly uploading blob with mismatched content type" do
    data = "Something else entirely!"
    blob = create_blob_before_direct_upload byte_size: data.size, checksum: Digest::MD5.base64digest(data)

    put blob.service_url_for_direct_upload, data, { 'CONTENT_TYPE' => "application/octet-stream" }
    assert_response :unprocessable_entity
    assert_not blob.service.exist?(blob.key)
  end

  test "directly uploading blob with mismatched content length" do
    data = "Something else entirely!"
    blob = create_blob_before_direct_upload byte_size: data.size - 1, checksum: Digest::MD5.base64digest(data)

    put blob.service_url_for_direct_upload, data, { 'CONTENT_TYPE' => "text/plain" }
    assert_response :unprocessable_entity
    assert_not blob.service.exist?(blob.key)
  end
end
