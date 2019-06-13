class TracksController < ApplicationController
  def search
    days_ago = params['days_ago'].to_i
    days_ago_filter = params['days_ago_filter'] || 'gt'
    limit = params['limit'] || 200
    bpm = params['bpm']
    bpm_filter = params['bpm_filter']
    release_date_start = params['release_date_start']
    release_date_end = params['release_date_end']
    
    @tracks = current_user.tracks

    if days_ago.present?
      if days_ago_filter.present? and days_ago_filter == 'gt'
        @tracks = @tracks.where('added_at < ?', days_ago.days.ago).order('added_at ASC')
      elsif days_ago_filter == 'lt'
        @tracks = @tracks.where('added_at > ?', days_ago.days.ago).order('added_at DESC')
      end
    end

    if bpm.present?
      if bpm_filter.present? and bpm_filter == 'lt'
        @tracks = @tracks.where("(audio_features ->> 'tempo')::numeric < ?", bpm)
      else
        @tracks = @tracks.where("(audio_features ->> 'tempo')::numeric > ?", bpm)
      end
    end

    if release_date_start.present? && release_date_end.present?
      @tracks = @tracks.joins(:album).where('release_date >= ? AND release_date <= ?', release_date_start, release_date_end)
    elsif release_date_start.present?
       @tracks = @tracks.joins(:album).where('release_date >= ?', release_date_start)
    elsif release_date_end.present?
       @tracks = @tracks.joins(:album).where('release_date <= ?', release_date_end)
    end




    if limit.present?
      @tracks = @tracks.limit(limit)
    end
  end
end
