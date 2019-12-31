class Playlist < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  after_save :build_spotify_playlist

  include Storext.model()

  def find_rule(rules, rule_name)
    rules.find{|r| r['id'] == rule_name} if rules.present?
  end


  def filtered_tracks(current_user)
    if full_catalog.present?
      tracks = Track.all
    else
      tracks = current_user.tracks.where('follows.active = ?', true)
    end

    rules = filters['rules']

    # TRACK NAME
    find_rule(rules, 'track_name').try do |rule|
      if rule['operator'] == 'contains'
        tracks = tracks.where('tracks.name ~* ?', rule['value'])
      elsif rule['operator'] == 'not_contains'
        tracks = tracks.where('tracks.name !~* ?', rule['value'])
      end
    end
    
    # ARTIST NAME
    find_rule(rules, 'artist_name').try do |rule|
      if rule['operator'] == 'contains'
        tracks = tracks.joins(:artist).where('artists.name ~* ?', rule['value'])
      elsif rule['operator'] == 'not_contains'
        tracks = tracks.joins(:artist).where('artists.name !~* ?', rule['value'])
      end
    end

    # LYRICS
    find_rule(rules, 'lyrics').try do |rule|
      if rule['operator'] == 'contains'
        tracks = tracks.where('lyrics ILIKE ?', '%' + rule['value'] + '%')
      elsif rule['operator'] == 'not_contains'
        tracks = tracks.where('lyrics NOT ILIKE ?', '%' + rule['value'] + '%')
      end
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
    if full_catalog.blank?
      find_rule(rules, 'days_ago').try do |rule|
        if rule['operator'] == 'less'
          tracks = tracks.where('follows.added_at > ?', rule['value'].days.ago).order('follows.added_at ASC')
        else
          tracks = tracks.where('follows.added_at < ?', rule['value'].days.ago).order('follows.added_at ASC')
        end
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
    if full_catalog.blank?
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
    if full_catalog.blank?
      find_rule(rules, 'last_played_days_ago').try do |rule|
        if rule['operator'] == 'less'
          tracks = tracks.where('follows.last_played_at < ?', rule['value'].days.ago).order('follows.last_played_at ASC')
        else
          tracks = tracks.where('follows.last_played_at > ?', rule['value'].days.ago).order('follows.last_played_at DESC')
        end
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
      when 'most_popular'
        tracks = tracks.order("tracks.popularity DESC NULLS LAST")
      when 'least_popular'
        tracks = tracks.order("tracks.popularity ASC NULLS LAST")
      when 'most_often_played'
        tracks = tracks.order("follows.plays DESC NULLS LAST") if full_catalog.blank?
      when 'least_often_played'
        tracks = tracks.order("follows.plays ASC NULLS LAST") if full_catalog.blank?
      when 'most_recently_added'
        tracks = tracks.order("follows.added_at DESC NULLS LAST") if full_catalog.blank?
      when 'least_recently_added'
        tracks = tracks.order("follows.added_at ASC NULLS LAST") if full_catalog.blank?
      when 'release_date_desc'
        tracks = tracks.joins(:album).order("albums.release_date DESC")
      when 'release_date_asc'
        tracks = tracks.joins(:album).order("albums.release_date ASC")
      end
    end

    # LIMIT
    if limit.present? and limit < 10000
      tracks = tracks.limit(limit)
    else
      tracks = tracks.limit(1000)
    end

    tracks
  end

  def build_spotify_playlist
    BuildPlaylistsWorker.perform_async(self.user.id)
  end

  def translated_rules
    filters['rules'].to_a.map { |item| "#{translate_field(item['field'])} #{translate_operator(item['operator'])} #{translate_value(item['field'], item['value'])}" }.join(", ")
  end

  def translate_field(field)
    if field == 'bpm'
      "BPM"
    else
      field = field.gsub("_", " ")
      field.titleize
    end
  end

  def translate_operator(operator)
    case operator
    when "equal"
      "is"
    when "between"
      "is between"
    when "less"
      "is less than"
    when "greater"
      "is greater than"
    when "in"
      "include"
    when "not_contains"
      "does not contain"
    else
      operator
    end
  end

  def translate_value(field, value)
    case field
    when "acousticness"
      case value
      when 0 # Not at all
        "Not at all"
      when 1 # Somewhat
        "Somewhat"
      when 2 # Likely
        "Likely"
      when 3 # Very likely
        "Very likely"
      end
    when "danceability"
      case value
      when 0 # Not at all
        "Not at all"
      when 1 # A little
        "A little"
      when 2 # Somewhat
        "Somewhat"
      when 3 # Moderately
        "Moderately"
      when 4 # Very
        "Very"
      when 5 # Super
        "Super"
      end
    when "key"
      case value
      when 0
        "C"
      when 1
        "C♯, D♭"
      when 2
        "D"
      when 3
        "D♯, E♭"
      when 4
        "E"
      when 5
        "F"
      when 6
        "F♯, G♭"
      when 7
        "G"
      when 8
        "G♯, A♭"
      when 9
        "A"
      when 10
        "A♯, B♭"
      when 11
        "B"
      end
    when "valence"
      case value
      when 0 
        "Negative (sad, depressed, angry)"
      when 1
        "Positive (happy, cheerful, euphoric)"
      end
    when "energy"
      case value
      when 0 
        "Low"
      when 1
        "Medium"
      when 2
        "High"
      when 3 
        "Insane"
      end
    when "instrumentalness"
      case value
      when 0 
        "No"
      when 1
        "Yes"
      end
    when "speechiness"
      case value
      when 0 
        "No"
      when 1
        "Yes"
      end
    when "release_date"
      "#{value[0].to_date.strftime("%b %-d, %Y")} and #{value[1].to_date.strftime("%b %-d, %Y")}"
    when "duration"
      if value[0] && value[1]
        "#{value[0]} and #{value[1]} seconds"
      else
        value
      end
    when "bpm"
      if value[0] && value[1]
        "#{value[0]} and #{value[1]}"
      else
        value
      end
    when "explicit"
      case value
      when 0
        "excluded"
      when 1
        "included"
      end
    when "mode"
      case value
      when 0
        "Minor"
      when 1
        "Major"
      end
    when "artist_name"
      "'#{value.gsub("|", " or ")}'"
    when "lyrics"
      "'#{value}'"
    when "track_name"
      "'#{value}'"
    when "genres"
      "'#{value.join(', ')}'"
    else
      value
    end
  end
end
