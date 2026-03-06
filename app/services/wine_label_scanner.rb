class WineLabelScanner
  class ScanError < StandardError; end

  PROMPT = <<~PROMPT
    Analyze this wine label and extract the following as JSON only,
    no explanation. Use null for fields you can't determine:
    {
      "winery": "string",
      "wine_name": "string",
      "vintage": "integer or null",
      "varietal": "string",
      "wine_type": "red|white|rosé|sparkling|dessert|fortified|null",
      "region": "string",
      "bottle_size_ml": "integer or null"
    }
  PROMPT

  def self.scan(base64_image, media_type: "image/jpeg")
    response = client.chat(
      parameters: {
        model: ENV.fetch("OPENAI_LABEL_MODEL", "gpt-4o"),
        response_format: { type: "json_object" },
        messages: [{
          role: "user",
          content: [
            { type: "text", text: PROMPT },
            { type: "image_url", image_url: { url: "data:#{media_type};base64,#{base64_image}" } }
          ]
        }],
        max_tokens: 300
      }
    )

    content = response.dig("choices", 0, "message", "content")
    raise ScanError, "Model returned empty content" if content.blank?

    JSON.parse(content)
  rescue JSON::ParserError, KeyError => e
    raise ScanError, "Could not parse label: #{e.message}"
  end

  def self.client
    @client ||= OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  private_class_method :client
end
