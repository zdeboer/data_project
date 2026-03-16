# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_03_16_162134) do
  create_table "character_issues", force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "issue_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_character_issues_on_character_id"
    t.index ["issue_id"], name: "index_character_issues_on_issue_id"
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.string "real_name"
    t.text "deck"
    t.string "image_url"
    t.integer "cv_id"
    t.integer "publisher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id"], name: "index_characters_on_publisher_id"
  end

  create_table "issues", force: :cascade do |t|
    t.string "name"
    t.string "issue_number"
    t.date "cover_date"
    t.string "image_url"
    t.text "description"
    t.integer "cv_id"
    t.integer "volume_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["volume_id"], name: "index_issues_on_volume_id"
  end

  create_table "publishers", force: :cascade do |t|
    t.string "name"
    t.text "deck"
    t.string "image_url"
    t.integer "cv_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "issue_id", null: false
    t.string "reviewer_name"
    t.integer "rating"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_reviews_on_issue_id"
  end

  create_table "volumes", force: :cascade do |t|
    t.string "name"
    t.integer "start_year"
    t.string "image_url"
    t.integer "cv_id"
    t.integer "publisher_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publisher_id"], name: "index_volumes_on_publisher_id"
  end

  add_foreign_key "character_issues", "characters"
  add_foreign_key "character_issues", "issues"
  add_foreign_key "characters", "publishers"
  add_foreign_key "issues", "volumes"
  add_foreign_key "reviews", "issues"
  add_foreign_key "volumes", "publishers"
end
