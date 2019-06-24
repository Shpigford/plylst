class Playlist < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  after_save :build_spotify_playlist

  include Storext.model()

  def find_rule(rules, rule_name)
    rules.find{|r| r['id'] == rule_name} if rules.present?
  end


  def filtered_tracks(current_user)
    tracks = current_user.tracks.where('follows.active = ?', true).limit(500)
    rules = filters['rules']

    # TRACK NAME
    find_rule(rules, 'track_name').try do |rule|
      tracks = tracks.where('tracks.name ILIKE ?', '%' + rule['value'] + '%')
    end
    
    # ARTIST NAME
    find_rule(rules, 'artist_name').try do |rule|
      tracks = tracks.joins(:artist).where('artists.name ILIKE ?', '%' + rule['value'] + '%')
    end

    # BPM
    find_rule(rules, 'bpm').try do |rule|
      if rule['operator'] == 'less'
        tracks = tracks.where("(audio_features ->> 'tempo')::numeric < ?", rule['value'])
      elsif rule['operator'] == 'greater'
        tracks = tracks.where("(audio_features ->> 'tempo')::numeric > ?", rule['value'])
      elsif rule['operator'] == 'between'
        tracks = tracks.where("(audio_features ->> 'tempo')::numeric between ? and ?", rule['value'][0], rule['value'][1])
      end
    end

    # DAYS AGO
    find_rule(rules, 'days_ago').try do |rule|
      if rule['operator'] == 'less'
        tracks = tracks.where('follows.added_at > ?', rule['value'].days.ago).order('follows.added_at ASC')
      else
        tracks = tracks.where('follows.added_at < ?', rule['value'].days.ago).order('follows.added_at ASC')
      end
    end

    # RELEASE DATE
    find_rule(rules, 'release_date').try do |rule|
      release_date_start = rule['value'][0]
      release_date_end = rule['value'][1]

      if release_date_start.scan(/\D/).empty? and (1700..2100).include?(release_date_start.to_i)
        release_date_start = "#{release_date_start}-01-01"
      end

      if release_date_end.scan(/\D/).empty? and (1700..2100).include?(release_date_end.to_i)
        release_date_end = "#{release_date_end}-12-31"
      end

      tracks = tracks.joins(:album).where('release_date >= ? AND release_date <= ?', release_date_start, release_date_end)
    end

    # GENRES
    find_rule(rules, 'genres').try do |rule|
      genres = rule['value']
      
      unless genres.kind_of?(Array)
        genres = genres.split(/\s*,\s*/)
      end
      
      tracks = tracks.joins(:artist).where("artists.genres ?| array[:genres]", genres: genres)
    end

    # PLAYS
    find_rule(rules, 'plays').try do |rule|
      if rule['value'].kind_of?(Array)
        plays_start = rule['value'][0] * 1000
        plays_end = rule['value'][1] * 1000
      else
        plays = rule['value'] * 1000
      end

      if rule['operator'] == 'less'
        tracks = tracks.where("follows.plays < ?", plays)
      elsif rule['operator'] == 'greater'
        tracks = tracks.where("follows.plays > ?", plays)
      elsif rule['operator'] == 'between'
        tracks = tracks.where("follows.plays between ? and ?", plays_start, plays_end)
      end
    end

    # DURATION
    find_rule(rules, 'duration').try do |rule|
      if rule['value'].kind_of?(Array)
        duration_start = rule['value'][0] * 1000
        duration_end = rule['value'][1] * 1000
      else
        duration = rule['value'] * 1000
      end

      if rule['operator'] == 'less'
        tracks = tracks.where("duration < ?", duration)
      elsif rule['operator'] == 'greater'
        tracks = tracks.where("duration > ?", duration)
      elsif rule['operator'] == 'between'
        tracks = tracks.where("duration between ? and ?", duration_start, duration_end)
      end
    end

    # DAYS SINCE LAST PLAYED
    find_rule(rules, 'last_played_days_ago').try do |rule|
      if rule['operator'] == 'less'
        tracks = tracks.where('last_played_at < ?', rule['value'].days.ago).order('last_played_at ASC')
      else
        tracks = tracks.where('last_played_at > ?', rule['value'].days.ago).order('last_played_at DESC')
      end
    end

    # KEY
    find_rule(rules, 'key').try do |rule|
      tracks = tracks.where("(audio_features ->> 'key')::numeric = ?", rule['value'])
    end

    # MODE
    find_rule(rules, 'mode').try do |rule|
      tracks = tracks.where("(audio_features ->> 'mode')::numeric = ?", rule['value'])
    end

    # DANCEABILITY
    find_rule(rules, 'danceability').try do |rule|
      case rule['value']
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

    # ACOUSTICNESS
    find_rule(rules, 'acousticness').try do |rule|
      case rule['value']
      when 0 # Not at all
        start = 0.0
        final = 0.250
      when 1 # Somewhat
        start = 0.251
        final = 0.500
      when 2 # Likely
        start = 0.501
        final = 0.750
      when 3 # Very likely
        start = 0.751
        final = 1.0
      end
      tracks = tracks.where("(audio_features ->> 'acousticness')::numeric between ? and ?", start, final)
    end

    # ENERGY
    find_rule(rules, 'energy').try do |rule|
      case rule['value']
      when 0 # Not at all
        start = 0.0
        final = 0.250
      when 1 # Somewhat
        start = 0.251
        final = 0.500
      when 2 # Somewhat
        start = 0.501
        final = 0.750
      when 3 # Very
        start = 0.751
        final = 1.0
      end
      tracks = tracks.where("(audio_features ->> 'energy')::numeric between ? and ?", start, final)
    end

    # INSTRUMENTALNESS
    find_rule(rules, 'instrumentalness').try do |rule|
      case rule['value']
      when 0 # Not at all
        start = 0.0
        final = 0.799
      when 1 # Somewhat
        start = 0.8
        final = 1.0
      end
      tracks = tracks.where("(audio_features ->> 'instrumentalness')::numeric between ? and ?", start, final)
    end

    # SPEECHINESS
    find_rule(rules, 'speechiness').try do |rule|
      case rule['value']
      when 0 # Not at all
        start = 0.0
        final = 0.66
      when 1 # Somewhat
        start = 0.667
        final = 1.0
      end
      tracks = tracks.where("(audio_features ->> 'speechiness')::numeric between ? and ?", start, final)
    end

    # EXPLICIT
    find_rule(rules, 'explicit').try do |rule|
      tracks = tracks.where('explicit = FALSE') if rule['value'] == 0
    end

    # VALENCE
    find_rule(rules, 'valence').try do |rule|
      case rule['value']
      when 0 # Not at all
        start = 0.0
        final = 0.5
      when 1 # Somewhat
        start = 0.51
        final = 1.0
      end
      tracks = tracks.where("(audio_features ->> 'valence')::numeric between ? and ?", start, final)
    end

    # SORT
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

    # LIMIT
    if limit.present?
      tracks = tracks.limit(limit)
    end

    tracks
  end

  def build_spotify_playlist
    BuildPlaylistsWorker.perform_async(self.user.id)
  end
end
