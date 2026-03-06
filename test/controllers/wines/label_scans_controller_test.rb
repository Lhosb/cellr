require "test_helper"
require "stringio"

module Wines
  class LabelScansControllerTest < ActionDispatch::IntegrationTest
    test "create returns parsed scan payload" do
      cellar = build_cellar
      payload = {
        "winery" => "Domaine Tempier",
        "wine_name" => "Bandol Rose",
        "vintage" => 2022
      }

      with_stubbed_scan_result(payload) do
        post scan_cellar_wine_label_path(cellar), params: { image: uploaded_image }
      end

      assert_response :ok
      assert_equal payload, JSON.parse(response.body)
    end

    test "create returns bad request when image is missing" do
      cellar = build_cellar

      post scan_cellar_wine_label_path(cellar), params: {}

      assert_response :bad_request
      assert_match "param is missing", JSON.parse(response.body).fetch("error")
    end

    test "create returns unprocessable entity when scan fails" do
      cellar = build_cellar

      with_stubbed_scan_error("scanner exploded") do
        post scan_cellar_wine_label_path(cellar), params: { image: uploaded_image }
      end

      assert_response :unprocessable_entity
      assert_equal "scanner exploded", JSON.parse(response.body).fetch("error")
    end

    private

    def uploaded_image
      Rack::Test::UploadedFile.new(StringIO.new("fake-image-bytes"), "image/jpeg", original_filename: "label.jpg")
    end

    def with_stubbed_scan_result(result)
      singleton = WineLabelScanner.singleton_class
      original_scan = singleton.instance_method(:scan)

      singleton.send(:define_method, :scan) { |_base64_image, media_type:| result }
      yield
    ensure
      singleton.send(:define_method, :scan, original_scan)
    end

    def with_stubbed_scan_error(message)
      singleton = WineLabelScanner.singleton_class
      original_scan = singleton.instance_method(:scan)

      singleton.send(:define_method, :scan) { |_base64_image, media_type:| raise WineLabelScanner::ScanError, message }
      yield
    ensure
      singleton.send(:define_method, :scan, original_scan)
    end
  end
end
