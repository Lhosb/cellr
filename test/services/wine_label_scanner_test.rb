require "test_helper"

class WineLabelScannerTest < ActiveSupport::TestCase
  FakeClient = Struct.new(:response, :captured_parameters, keyword_init: true) do
    def chat(parameters:)
      self.captured_parameters = parameters
      response
    end
  end

  test "scan parses JSON response" do
    fake = FakeClient.new(
      response: {
        "choices" => [
          { "message" => { "content" => { winery: "Domaine Tempier", vintage: 2022 }.to_json } }
        ]
      }
    )

    result = with_fake_client(fake) do
      WineLabelScanner.scan(Base64.strict_encode64("image-bytes"), media_type: "image/png")
    end

    assert_equal "Domaine Tempier", result["winery"]
    assert_equal 2022, result["vintage"]
    assert_equal "gpt-4o", fake.captured_parameters[:model]
    assert_includes fake.captured_parameters[:messages].first[:content].last[:image_url][:url], "data:image/png;base64,"
  end

  test "scan raises error on empty content" do
    fake = FakeClient.new(response: { "choices" => [ { "message" => { "content" => "" } } ] })

    error = assert_raises(WineLabelScanner::ScanError) do
      with_fake_client(fake) { WineLabelScanner.scan("abc") }
    end

    assert_match "empty content", error.message
  end

  test "scan raises error when json is invalid" do
    fake = FakeClient.new(response: { "choices" => [ { "message" => { "content" => "{bad-json" } } ] })

    error = assert_raises(WineLabelScanner::ScanError) do
      with_fake_client(fake) { WineLabelScanner.scan("abc") }
    end

    assert_match "Could not parse label", error.message
  end

  private

  def with_fake_client(fake_client)
    singleton = WineLabelScanner.singleton_class
    original_client = singleton.instance_method(:client)
    singleton.send(:define_method, :client) { fake_client }
    singleton.send(:private, :client)

    yield
  ensure
    singleton.send(:define_method, :client, original_client)
    singleton.send(:private, :client)
  end
end
