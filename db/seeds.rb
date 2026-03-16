# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'net/http'
require 'json'

BASE_URL = "https://comicvine.gamespot.com/api"
API_KEY  = ENV["COMIC_VINE_API_KEY"]

def comic_vine_get(resource, params = {})
  query = params.merge(api_key: API_KEY, format: "json").to_query
  uri = URI("#{BASE_URL}/#{resource}/?#{query}")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "IntroDataProject/1.0"

  response = http.request(request)
  JSON.parse(response.body)
end

# Test it
result = comic_vine_get("publishers", limit: 10)
puts result["status_code"]
