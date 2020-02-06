class Album < ApplicationRecord
  belongs_to :artist
  has_many :tracks

  validates :spotify_id, uniqueness: true
end
