class Playlist < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  after_save :build_spotify_playlist

  include Storext.model()
  store_attributes :variables do
    days_ago Integer
    limit Integer, default: 500
    bpm Integer
    days_ago_filter String, default: 'gt'
    bpm_filter String
    release_date_start String
    release_date_end String
    genres String
    plays Integer
    plays_filter String
    last_played_days_ago Integer
    last_played_days_ago_filter String
    duration Integer
    duration_filter String
    key Integer
    danceability Integer
    sort String
    track_name String
    artist_name String
  end

  def filtered_tracks(current_user)
    days_ago = variables['days_ago']
    days_ago_filter = variables['days_ago_filter'] || 'gt'
    limit = variables['limit'] || 200
    bpm = variables['bpm']
    bpm_filter = variables['bpm_filter']
    release_date_start = variables['release_date_start']
    release_date_end = variables['release_date_end']
    genres = variables['genres']
    plays = variables['plays']
    plays_filter = variables['plays_filter'] || 'gt'
    last_played_days_ago = variables['last_played_days_ago']
    last_played_days_ago_filter = variables['last_played_days_ago_filter']
    duration = variables['duration']
    duration_filter = variables['duration_filter']
    key = variables['key']
    danceability = variables['danceability']
    sort = variables['sort']
    track_name = variables['track_name']
    artist_name = variables['artist_name']
    
    tracks = current_user.tracks

    if track_name.present?
      tracks = tracks.advanced_search(name: track_name)
    end

    if artist_name.present?
      tracks = tracks.joins(:artist).where('artists.name ILIKE ?', '%' + artist_name + '%')
    end

    if days_ago.present?
      days_ago = days_ago.to_i
      if days_ago_filter.present? and days_ago_filter == 'gt'
        tracks = tracks.where('follows.added_at < ?', days_ago.days.ago).order('follows.added_at ASC')
      elsif days_ago_filter == 'lt'
        tracks = tracks.where('follows.added_at > ?', days_ago.days.ago).order('follows.added_at DESC')
      end
    end

    if bpm.present?
      if bpm_filter.present? and bpm_filter == 'lt'
        tracks = tracks.where("(audio_features ->> 'tempo')::numeric < ?", bpm)
      else
        tracks = tracks.where("(audio_features ->> 'tempo')::numeric > ?", bpm)
      end
    end

    if release_date_start.present? && release_date_end.present?

      if release_date_start.scan(/\D/).empty? and (1700..2100).include?(release_date_start.to_i)
        release_date_start = "#{release_date_start}-01-01"
      end

      if release_date_end.scan(/\D/).empty? and (1700..2100).include?(release_date_end.to_i)
        release_date_end = "#{release_date_end}-12-31"
      end

      tracks = tracks.joins(:album).where('release_date >= ? AND release_date <= ?', release_date_start, release_date_end)
    elsif release_date_start.present?
       tracks = tracks.joins(:album).where('release_date >= ?', release_date_start)
    elsif release_date_end.present?
       tracks = tracks.joins(:album).where('release_date <= ?', release_date_end)
    end

    if genres.present?
      genres = genres.split(/\s*,\s*/)
      tracks = tracks.joins(:artist).where("artists.genres ?| array[:genres]", genres: genres)
    end

    if plays.present?
      plays = plays.to_i
      if plays_filter.present? and plays_filter == 'gt'
        tracks = tracks.where("follows.plays > ?", plays)
      elsif plays_filter == 'lt'
        tracks = tracks.where("follows.plays < ?", plays)
      end
    end

    if duration.present?
      duration = duration * 1000
      if duration_filter.present? and duration_filter == 'gt'
        tracks = tracks.where("duration > ?", duration)
      elsif duration_filter == 'lt'
        tracks = tracks.where("duration < ?", duration)
      end
    end

    if last_played_days_ago.present?
      last_played_days_ago = last_played_days_ago.to_i
      if last_played_days_ago_filter.present? and last_played_days_ago_filter == 'gt'
        tracks = tracks.where('last_played_at < ?', last_played_days_ago.days.ago).order('last_played_at ASC')
      elsif last_played_days_ago_filter == 'lt'
        tracks = tracks.where('last_played_at > ?', last_played_days_ago.days.ago).order('last_played_at DESC')
      end
    end

    if key.present?
      tracks = tracks.where("(audio_features ->> 'key')::numeric = ?", key)
    end

    if danceability.present?
      case danceability
      when 0 # Not at all
        start = 0.0
        final = 0.199
      when 1 # A little
        start = 0.2
        final = 0.399
      when 2 # Somewhat
        start = 0.4
        final = 0.599
      when 3 # Moderately
        start = 0.6
        final = 0.799
      when 4 # Very
        start = 0.8
        final = 0.899
      when 5 # Super
        start = 0.9
        final = 1.0
      end
      tracks = tracks.where("(audio_features ->> 'danceability')::numeric between ? and ?", start, final)
    end

    if sort.present?
      case sort
      when 'random'
        tracks = tracks.order("random()")
      when 'most_often_played'
        tracks = tracks.order("follows.plays DESC NULLS LAST")
      when 'least_often_played'
        tracks = tracks.order("follows.plays ASC NULLS LAST")
      when 'most_recently_added'
        tracks = tracks.order("follows.added_at DESC NULLS LAST")
      when 'least_recently_added'
        tracks = tracks.order("follows.added_at ASC NULLS LAST")
      end
    end

    if limit.present?
      tracks = tracks.limit(limit)
    end

    tracks
  end

  def build_spotify_playlist
    BuildPlaylistsWorker.perform_async(self.user.id)
  end
end
