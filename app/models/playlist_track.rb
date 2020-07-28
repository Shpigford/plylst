class PlaylistTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :track

  validates :playlist_id, :track_id, presence: true
  validates_uniqueness_of :playlist_id, scope: :track_id
end