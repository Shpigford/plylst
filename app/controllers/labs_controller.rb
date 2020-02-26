class LabsController < ApplicationController
  def index

  end

  def most_listened_tracks
    @tracks = Follow.where('plays > 0').group(:track_id).select('SUM(plays) as total_plays', :track_id).includes(:track).order('total_plays DESC').limit(100)
    @hide_sidebar = true
  end

  def record_labels
    @labels = Rails.cache.fetch("record_labels", expires_in: 24.hours) do
      Album.pluck(:label).reject!(&:blank?).flatten.group_by(&:itself).map { |k,v| [k, v.count] }.to_h.sort_by{|k,v| v}.reverse
    end
    @hide_sidebar = true
  end
end
