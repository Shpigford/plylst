# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_03_192041) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "albums", force: :cascade do |t|
    t.bigint "artist_id"
    t.text "name"
    t.text "image"
    t.date "release_date"
    t.text "spotify_id"
    t.text "link"
    t.integer "popularity"
    t.string "album_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_albums_on_artist_id"
    t.index ["spotify_id"], name: "index_albums_on_spotify_id"
  end

  create_table "artists", force: :cascade do |t|
    t.text "name"
    t.text "spotify_id"
    t.integer "followers"
    t.integer "popularity"
    t.text "images"
    t.text "link"
    t.jsonb "genres"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["spotify_id"], name: "index_artists_on_spotify_id"
  end

  create_table "follows", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "track_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "added_at"
    t.datetime "last_played_at"
    t.integer "plays"
    t.index ["track_id"], name: "index_follows_on_track_id"
    t.index ["user_id", "track_id"], name: "index_follows_on_user_id_and_track_id"
    t.index ["user_id"], name: "index_follows_on_user_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.jsonb "variables"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "filters", default: {}, null: false
    t.integer "limit"
    t.string "sort"
    t.boolean "full_catalog", default: false
    t.index ["full_catalog"], name: "index_playlists_on_full_catalog"
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "streams", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "track_id"
    t.datetime "played_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["track_id"], name: "index_streams_on_track_id"
    t.index ["user_id"], name: "index_streams_on_user_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.bigint "album_id"
    t.bigint "artist_id"
    t.integer "duration"
    t.boolean "explicit"
    t.text "spotify_id"
    t.text "link"
    t.text "name"
    t.integer "popularity"
    t.text "preview_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "audio_features"
    t.text "lyrics"
    t.index ["album_id"], name: "index_tracks_on_album_id"
    t.index ["artist_id"], name: "index_tracks_on_artist_id"
    t.index ["explicit"], name: "index_tracks_on_explicit"
    t.index ["spotify_id"], name: "index_tracks_on_spotify_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "provider"
    t.string "uid"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "settings"
    t.boolean "active", default: true
    t.jsonb "genres", default: {}
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "albums", "artists"
  add_foreign_key "follows", "tracks"
  add_foreign_key "follows", "users"
  add_foreign_key "playlists", "users"
  add_foreign_key "streams", "tracks"
  add_foreign_key "streams", "users"
  add_foreign_key "tracks", "albums"
  add_foreign_key "tracks", "artists"
end
