module Wines
  class LabelScansController < ApplicationController
    def create
      uploaded = params.require(:image)
      base64_image = Base64.strict_encode64(uploaded.read)
      media_type = uploaded.content_type.presence || "image/jpeg"

      result = WineLabelScanner.scan(base64_image, media_type:)
      render json: result, status: :ok
    rescue ActionController::ParameterMissing => e
      render json: { error: e.message }, status: :bad_request
    rescue WineLabelScanner::ScanError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
