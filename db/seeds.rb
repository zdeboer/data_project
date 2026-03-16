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

# ── Publishers ──────────────────────────────────────────────
puts "Seeding publishers..."

result = comic_vine_get("publishers", limit: 30, offset: 0)
result["results"].each do |p|
  Publisher.find_or_create_by(cv_id: p["id"]) do |pub|
    pub.name      = p["name"]
    pub.deck      = p["deck"]
    pub.image_url = p.dig("image", "medium_url")
  end
end
puts "  #{Publisher.count} publishers seeded"

# ── Volumes ──────────────────────────────────────────────────
puts "Seeding volumes..."

Publisher.all.each do |publisher|
  result = comic_vine_get("volumes", limit: 10, offset: 0, filter: "publisher:#{publisher.cv_id}")
  result["results"].each do |v|
    Volume.find_or_create_by(cv_id: v["id"]) do |vol|
      vol.name         = v["name"]
      vol.start_year   = v["start_year"]
      vol.image_url    = v.dig("image", "medium_url")
      vol.publisher_id = publisher.id
    end
  end
end
puts "  #{Volume.count} volumes seeded"

# ── Issues ───────────────────────────────────────────────────
puts "Seeding issues..."

Volume.all.each do |volume|
  result = comic_vine_get("issues", limit: 10, offset: 0, filter: "volume:#{volume.cv_id}")
  result["results"].each do |i|
    Issue.find_or_create_by(cv_id: i["id"]) do |iss|
      iss.name         = i["name"]
      iss.issue_number = i["issue_number"]
      iss.cover_date   = i["cover_date"]
      iss.image_url    = i.dig("image", "medium_url")
      iss.description  = i["deck"]
      iss.volume_id    = volume.id
    end
  end
end
puts "  #{Issue.count} issues seeded"

# ── Characters ───────────────────────────────────────────────
puts "Seeding characters..."

result = comic_vine_get("characters", limit: 100, offset: 0)
result["results"].each do |c|
  publisher = Publisher.find_by(cv_id: c.dig("publisher", "id"))
  Character.find_or_create_by(cv_id: c["id"]) do |char|
    char.name         = c["name"]
    char.real_name    = c["real_name"]
    char.deck         = c["deck"]
    char.image_url    = c.dig("image", "medium_url")
    char.publisher_id = publisher&.id
  end
end
puts "  #{Character.count} characters seeded"

# ── Character Issues ─────────────────────────────────────────
puts "Seeding character issues..."

Issue.all.each do |issue|
  next unless issue.cv_id

  result = comic_vine_get("issue/4000-#{issue.cv_id}", {})
  character_credits = result.dig("results", "character_credits") || []

  character_credits.first(5).each do |c|
    # Create the character if we don't have them yet
    character = Character.find_or_create_by(cv_id: c["id"]) do |char|
      char.name  = c["name"]
      char.deck  = nil
      char.image_url = nil
    end

    CharacterIssue.find_or_create_by(
      character_id: character.id,
      issue_id:     issue.id
    )
  end

  sleep(0.5)
end

puts "  #{CharacterIssue.count} character issues seeded"

# ── Reviews (Faker) ──────────────────────────────────────────
puts "Seeding reviews..."

require 'faker'
Issue.all.each do |issue|
  rand(1..4).times do
    Review.create(
      issue_id:      issue.id,
      reviewer_name: Faker::Name.name,
      rating:        rand(1..5),
      body:          Faker::Lorem.paragraph(sentence_count: 3)
    )
  end
end
puts "  #{Review.count} reviews seeded"

puts "Done! Database summary:"
puts "  Publishers: #{Publisher.count}"
puts "  Volumes:    #{Volume.count}"
puts "  Issues:     #{Issue.count}"
puts "  Characters: #{Character.count}"
puts "  Reviews:    #{Review.count}"
puts "  Character Issues: #{CharacterIssue.count}"
