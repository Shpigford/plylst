class Album < ApplicationRecord
  belongs_to :artist
  has_many :tracks
end
