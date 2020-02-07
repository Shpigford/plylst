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

ActiveRecord::Schema.define(version: 2020_02_07_163126) do

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
    t.datetime "last_checked_at"
    t.index ["last_checked_at"], name: "index_artists_on_last_checked_at"
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
    t.index ["user_id", "track_id"], name: "index_follows_on_user_id_and_track_id", unique: true
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
    t.boolean "auto_update", default: true
    t.boolean "public", default: true
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
    t.index ["user_id", "track_id", "played_at"], name: "index_streams_on_user_id_and_track_id_and_played_at", unique: true
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
    t.text "lyrics"
    t.datetime "lyrics_last_checked_at"
    t.datetime "audio_features_last_checked"
    t.integer "key"
    t.integer "mode"
    t.decimal "tempo"
    t.decimal "energy"
    t.decimal "valence"
    t.decimal "liveness"
    t.decimal "loudness"
    t.decimal "speechiness"
    t.decimal "acousticness"
    t.decimal "danceability"
    t.integer "time_signature"
    t.decimal "instrumentalness"
    t.index ["acousticness"], name: "index_tracks_on_acousticness"
    t.index ["album_id"], name: "index_tracks_on_album_id"
    t.index ["artist_id"], name: "index_tracks_on_artist_id"
    t.index ["audio_features_last_checked"], name: "index_tracks_on_audio_features_last_checked"
    t.index ["danceability"], name: "index_tracks_on_danceability"
    t.index ["energy"], name: "index_tracks_on_energy"
    t.index ["explicit"], name: "index_tracks_on_explicit"
    t.index ["instrumentalness"], name: "index_tracks_on_instrumentalness"
    t.index ["key"], name: "index_tracks_on_key"
    t.index ["liveness"], name: "index_tracks_on_liveness"
    t.index ["loudness"], name: "index_tracks_on_loudness"
    t.index ["lyrics_last_checked_at"], name: "index_tracks_on_lyrics_last_checked_at"
    t.index ["mode"], name: "index_tracks_on_mode"
    t.index ["speechiness"], name: "index_tracks_on_speechiness"
    t.index ["spotify_id"], name: "index_tracks_on_spotify_id"
    t.index ["tempo"], name: "index_tracks_on_tempo"
    t.index ["time_signature"], name: "index_tracks_on_time_signature"
    t.index ["valence"], name: "index_tracks_on_valence"
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
    t.integer "authorization_fails", default: 0
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
