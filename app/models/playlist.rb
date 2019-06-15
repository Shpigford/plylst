class Playlist < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  include Storext.model()
  store_attributes :variables do
    days_ago Integer
    limit Integer
    bpm Integer
    days_ago_filter String
    bpm_filter String
    release_date_start String
    release_date_end String
  end
end
