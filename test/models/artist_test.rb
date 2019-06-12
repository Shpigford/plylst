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

require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
