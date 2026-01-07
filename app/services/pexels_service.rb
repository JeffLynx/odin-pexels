class PexelsService
  BASE_URL = "https://api.pexels.com/v1"

  def initialize(api_key)
    @api_key = api_key
  end

  def search(query, per_page: 20)
    puts "🔍 Searching for: #{query}"
    response = connection.get("/search") do |request|
      request.params["query"] = query
      request.params["per_page"] = per_page
    end

    puts "📊 Response status: #{response.status}"
    puts "📊 Response headers: #{response.headers.inspect}"

    if response.success?
      data = JSON.parse(response.body)
      puts "📸 Found #{data['total_results']} total results"
      puts "📸 Photos count: #{data['photos']&.count || 0}"
      data
    else
      puts "❌ API Error: #{response.status} - #{response.body}"
      nil
    end
  end

  def popular(per_page: 20)
    response = connection.get("/popular") do |request|
      request.params["per_page"] = per_page
    end

    JSON.parse(response.body) if response.success?
  end

  def get_collection_photos(collection_slug, per_page: 20)
    puts "🔍 Getting collection: #{collection_slug}"

    response = connection.get("/collections/#{collection_slug}") do |request|
    end

    puts "📊 Collection endpoint status: #{response.status}"

    if response.success?
      collection_data = JSON.parse(response.body)
      puts "📸 Collection ID: #{collection_data['id']}"
      puts "📸 Collection title: #{collection_data['title']}"

      response = connection.get("/collections/#{collection_data['id']}/photos") do |request|
        request.params["per_page"] = per_page
      end

      if response.success?
        data = JSON.parse(response.body)
        puts "📸 Found #{data['total_results']} photos in collection"
        return data
      end
    end

    nil
  end

  private

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |builder|
      builder.request :json
      builder.response :json, content_type: /\bjson$/
      builder.adapter Faraday.default_adapter
    end.tap do |conn|
      conn.headers["Authorization"] = @api_key
    end
  end
end
