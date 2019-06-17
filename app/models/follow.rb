class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :track
  has_many :streams, through: :track
end
