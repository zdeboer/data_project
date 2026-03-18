require 'net/http'
require 'json'
require 'faker'

BASE_URL = "https://comicvine.gamespot.com/api"
API_KEY  = ENV["COMIC_VINE_API_KEY"]

def comic_vine_get(resource, params = {})
  query = params.merge(api_key: API_KEY, format: "json").to_query
  uri = URI("#{BASE_URL}/#{resource}/?#{query}")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "MyComicApp/1.0"

  retries = 0
  begin
    response = http.request(request)
    sleep(1.1)
    data = JSON.parse(response.body)

    if data["status_code"] == 107
      puts "\n  Rate limited! Waiting for it to clear..."
      sleep(3600)
      raise JSON::ParserError
    end

    unless data["status_code"] == 1
      puts "\n  API error #{data["status_code"]}: #{data["error"]} — skipping #{resource}"
      return { "results" => [] }
    end

    data
  rescue JSON::ParserError
    retries += 1
    if retries <= 3
      puts "  Waiting 10 seconds before retry #{retries}/3..."
      sleep(10)
      retry
    else
      puts "  Failed after 3 retries, skipping #{resource}"
      { "results" => [] }
    end
  rescue => e
    puts "  Unexpected error: #{e.message} — skipping #{resource}"
    { "results" => [] }
  end
end

# ── Publishers ──────────────────────────────────────────────
puts "Seeding publishers..."

TOP_PUBLISHER_IDS = [ 31, 10, 101 ]
# 31=Marvel, 10=DC, 101=Archie

TOP_PUBLISHER_IDS.each do |cv_id|
  next if Publisher.exists?(cv_id: cv_id)

  result = comic_vine_get("publisher/4010-#{cv_id}", {})
  pub_data = result["results"]
  next unless pub_data.is_a?(Hash)

  Publisher.create(
    cv_id:     pub_data["id"],
    name:      pub_data["name"],
    deck:      pub_data["deck"],
    image_url: pub_data.dig("image", "medium_url")
  )
  puts "  Created publisher: #{pub_data["name"]}"
end

puts "  #{Publisher.count} publishers seeded"

# ── Volumes ──────────────────────────────────────────────────
puts "Seeding volumes..."

POPULAR_VOLUME_IDS = [
  # Marvel
  2127,   # The Amazing Spider-Man (1963)
  2128,   # The Avengers (1963)
  2045,   # Fantastic Four (1961)
  2190,   # Daredevil (1964)
  2400,   # Captain America (1968)
  2406,   # The Incredible Hulk (1968)
  2407,   # Iron Man (1968)
  3092,   # The Uncanny X-Men (1981)
  2133,   # The X-Men (1963)
  10809,  # Wolverine (2003)
  43539,  # Wolverine & the X-Men (2011)
  85930,  # All-New Wolverine (2015)
  95402,  # Avengers (2016)
  18220,  # Iron Man (2004)
  43516,  # Incredible Hulk (2011)
  # DC
  796,    # Batman (1940)
  773,    # Superman (1939)
  3824,   # Wonder Woman (1987)
  5755,   # Nightwing (1996)
  2279,   # Teen Titans
  91098,  # Detective Comics (2016)
  # Archie
  1898,   # Archie Comics
  9628,   # Archie
  92353,  # Betty & Veronica
  20115,  # Archie's Pal Jughead Comics
  29250,  # Archie's Girls Betty and Veronica
  36409   # Archie's Pal Jughead
]

POPULAR_VOLUME_IDS.each do |cv_id|
  next if Volume.exists?(cv_id: cv_id)

  result = comic_vine_get("volume/4050-#{cv_id}", {})
  vol_data = result["results"]
  next unless vol_data.is_a?(Hash)

  publisher = Publisher.find_by(cv_id: vol_data.dig("publisher", "id"))
  next unless publisher

  Volume.create(
    cv_id:        vol_data["id"],
    name:         vol_data["name"],
    start_year:   vol_data["start_year"],
    image_url:    vol_data.dig("image", "medium_url"),
    publisher_id: publisher.id
  )
  puts "  Created volume: #{vol_data["name"]}"
end

puts "  #{Volume.count} volumes seeded"

# ── Issues ───────────────────────────────────────────────────
puts "Seeding issues..."

Volume.all.each do |volume|
  next unless volume.cv_id
  next if Issue.where(volume_id: volume.id).any?

  offset = 0
  loop do
    result = comic_vine_get("issues", limit: 100, offset: offset,
      filter: "volume:#{volume.cv_id}"
    )
    batch = result["results"]
    break if !batch.is_a?(Array) || batch.empty?

    batch.each do |i|
      next unless i.is_a?(Hash)
      next if Issue.exists?(cv_id: i["id"])

      Issue.create(
        cv_id:        i["id"],
        name:         i["name"].presence || "Issue ##{i["issue_number"]}",
        issue_number: i["issue_number"],
        cover_date:   i["cover_date"],
        image_url:    i.dig("image", "medium_url"),
        description:  i["deck"],
        volume_id:    volume.id
      )
    end

    puts "  Issues so far: #{Issue.count}"
    break if batch.size < 100
    offset += 100
  end
end

puts "  #{Issue.count} issues seeded"

# ── Characters + Character Issues ────────────────────────────
puts "Seeding characters and character issues..."

remaining = Issue.where(characters_seeded: [ false, nil ]).where.not(cv_id: nil).count

if remaining == 0
  puts "  All issues already processed, skipping..."
else
  puts "  #{remaining} issues still need processing..."

  total_issues = Issue.count

  Issue.where(characters_seeded: [ false, nil ]).where.not(cv_id: nil).each do |issue|
    result = comic_vine_get("issue/4000-#{issue.cv_id}", {})
    results = result["results"]

    if results.is_a?(Hash)
      character_credits = results["character_credits"] || []

      character_credits.each do |c|
        next unless c.is_a?(Hash)
        next if c["name"].blank?

        character = Character.find_or_create_by(cv_id: c["id"]) do |char|
          char.name      = c["name"]
          char.image_url = nil
          char.deck      = nil
        end

        next unless character.persisted?

        CharacterIssue.find_or_create_by(
          character_id: character.id,
          issue_id:     issue.id
        )
      end

      issue.update_column(:characters_seeded, true)
    end

    done = Issue.where(characters_seeded: true).count
    percentage = ((done.to_f / total_issues) * 100).round(1)
    print "\r  Progress: #{done}/#{total_issues} (#{percentage}%) — Characters: #{Character.count}, CharacterIssues: #{CharacterIssue.count}"
  end
end

puts "\n  #{Character.count} characters seeded"
puts "  #{CharacterIssue.count} character issues seeded"

# ── Enrich Characters ────────────────────────────────────────
puts "Enriching character details..."

needs_enrichment = Character.where("image_url IS NULL OR real_name IS NULL OR deck IS NULL OR publisher_id IS NULL")
total = needs_enrichment.count
enriched = 0

if total == 0
  puts "  All characters already enriched, skipping..."
else
  puts "  #{total} characters need enriching..."

  needs_enrichment.each do |character|
    next unless character.cv_id

    result = comic_vine_get("character/4005-#{character.cv_id}", {})
    char_data = result["results"]
    next unless char_data.is_a?(Hash)

    publisher = Publisher.find_by(cv_id: char_data.dig("publisher", "id"))

    character.update(
      real_name:    char_data["real_name"],
      deck:         char_data["deck"],
      image_url:    char_data.dig("image", "medium_url"),
      publisher_id: publisher&.id
    )

    enriched += 1
    percentage = (enriched.to_f / total * 100).round(1)
    print "\r  Enriching: #{enriched}/#{total} (#{percentage}%)"
  end

  puts "\n  Done enriching!"
end

# ── Reviews (Faker) ──────────────────────────────────────────
puts "Seeding reviews..."

Issue.all.each do |issue|
  next if Review.where(issue_id: issue.id).any?

  rand(1..5).times do
    Review.create(
      issue_id:      issue.id,
      reviewer_name: Faker::Name.name,
      rating:        rand(1..5),
      body:          Faker::Lorem.paragraph(sentence_count: 3)
    )
  end
end

puts "  #{Review.count} reviews seeded"

puts "\nDone! Database summary:"
puts "  Publishers:       #{Publisher.count}"
puts "  Volumes:          #{Volume.count}"
puts "  Issues:           #{Issue.count}"
puts "  Characters:       #{Character.count}"
puts "  Character Issues: #{CharacterIssue.count}"
puts "  Reviews:          #{Review.count}"
puts "  TOTAL:            #{Publisher.count + Volume.count + Issue.count + Character.count + CharacterIssue.count + Review.count}"
