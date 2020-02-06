# == Schema Information
#
# Table name: artists
#
#  id         :bigint           not null, primary key
#  name       :text
#  spotify_id :text
#  followers  :integer
#  popularity :integer
#  images     :text
#  link       :text
#  genres     :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Artist < ApplicationRecord
  has_many :albums
  has_many :tracks

  validates :spotify_id, uniqueness: true

  include Storext.model(genres: {})
end
