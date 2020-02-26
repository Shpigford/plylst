class LabsController < ApplicationController
  def index

  end

  def most_listened_tracks
    @tracks = Follow.where('plays > 0').group(:track_id).select('SUM(plays) as total_plays', :track_id).includes(:track).order('total_plays DESC').limit(100)
    @hide_sidebar = true
  end

  def labels
    @labels = Album.pluck(:label).flatten.group_by(&:itself).map { |k,v| [k, v.count] }.to_h.sort_by{|k,v| v}.reverse
    @hide_sidebar = true
  end
end
