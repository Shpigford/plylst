class LabsController < ApplicationController
  def index

  end

  def most_listened_tracks
    @tracks = Follow.where('plays > 0').group(:track_id, :id).select('SUM(plays) as total_plays', :track_id).includes(:track).order('total_plays DESC').limit(100)
  end
end
