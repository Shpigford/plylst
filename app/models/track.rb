class Track < ApplicationRecord
  belongs_to :album
  belongs_to :artist
  has_many :follows, dependent:  :destroy
  has_and_belongs_to_many :users, join_table: :follows
  has_many :streams
  has_many :playlist_tracks
  has_many :playlists, through: :playlist_tracks

  validates :spotify_id, uniqueness: true
end
