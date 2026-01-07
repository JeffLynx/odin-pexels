class StaticPagesController < ApplicationController
  def home
    return unless params[:collection_id].present?

    service = PexelsService.new(Rails.application.credentials.pexels.api_key)

    begin
      response = service.get_collection_photos(params[:collection_id], per_page: 20)

      @photos = response["photos"] if response

    rescue StandardError => e
      @error = e.message
    end
  end
end
