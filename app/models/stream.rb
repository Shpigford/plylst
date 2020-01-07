class Stream < ApplicationRecord
  belongs_to :user
  belongs_to :track

  validates :user, uniqueness: { scope: [:track, :played_at] }
end
