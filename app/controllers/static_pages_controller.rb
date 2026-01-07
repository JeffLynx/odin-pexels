class StaticPagesController < ApplicationController
  def home
    return unless params[:collection_id].present?

    client = Pexels::Client.new(
      api_key: Rails.application.credentials.pexels.api_key
    )

    response = client.collections
      .find(params[:collection_id])
      .media

    @photos = response.photos
  rescue StandardError => e
    @error = e.message
  end
end
