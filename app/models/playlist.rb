class Playlist < ApplicationRecord
  include Hashid::Rails
  
  belongs_to :user

  validates :name, presence: true

  after_save :build_spotify_playlist

  include Storext.model()

  def find_rule(rules, rule_name)
    rules.find{|r| r['id'] == rule_name} if rules.present?
  end

  def filtered_tracks(current_user)
    if catalog == 'full'
      tracks = Track.all
    elsif catalog == 'artists'
      tracks = Track.where(artist_id: current_user.artists.group(:id).pluck(:id))
    else
      tracks = current_user.tracks.where('follows.active = ?', true)
    end

    rules = filters['rules']

    # TRACK NAME
    find_rule(rules, 'track_name').try do |rule|
      if rule['operator'] == 'contains'
        tracks = tracks.where('tracks.name ~* ?', rule['value'].gsub('$', '\$'))
      elsif rule['operator'] == 'not_contains'
        tracks = tracks.where('tracks.name !~* ?', rule['value'].gsub('$', '\$'))
      elsif rule['operator'] == 'equal'
        tracks = tracks.where('tracks.name = ?', rule['value'].gsub('$', '\$'))
      elsif rule['operator'] == 'not_equal'
        tracks = tracks.where('tracks.name != ?', rule['value'].gsub('$', '\$'))
      elsif rule['operator'] == 'begins_with'
        tracks = tracks.where('tracks.name ILIKE ?', rule['value'].gsub('$', '\$') + '%')
      elsif rule['operator'] == 'ends_with'
        tracks = tracks.where('tracks.name ILIKE ?', '%' + rule['value'].gsub('$', '\$'))
      end
    end
    
    # ARTIST NAME
    find_rule(rules, 'artist_name').try do |rule|
      if rule['operator'] == 'contains'
        tracks = tracks.joins(:artist).where('artists.name ~* ?', rule['value'].gsub('$', '\$'))
      elsif rule['operator'] == 'not_contains'
        tracks = tracks.joins(:artist).where('artists.name !~* ?', rule['value'].gsub('$', '\$'))
      elsif rule['operator'] == 'equal'
        tracks = tracks.joins(:artist).where('artists.name = ?', rule['value'].gsub('$', '\$'))
      elsif rule['operator'] == 'not_equal'
        tracks = tracks.joins(:artist).where('artists.name != ?', rule['value'].gsub('$', '\$'))
      elsif rule['operator'] == 'begins_with'
        tracks = tracks.joins(:artist).where('artists.name ILIKE ?', rule['value'].gsub('$', '\$') + '%')
      elsif rule['operator'] == 'ends_with'
        tracks = tracks.joins(:artist).where('artists.name ILIKE ?', '%' + rule['value'].gsub('$', '\$'))
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
        tracks = tracks.where("tempo < ?", rule['value'])
      elsif rule['operator'] == 'greater'
        tracks = tracks.where("tempo > ?", rule['value'])
      elsif rule['operator'] == 'between'
        tracks = tracks.where("tempo between ? and ?", rule['value'][0], rule['value'][1])
      end
    end

    # DAYS AGO
    if catalog == 'songs'
      find_rule(rules, 'days_ago').try do |rule|
        if rule['operator'] == 'less'
          tracks = tracks.where('follows.added_at > ?', rule['value'].days.ago).order('follows.added_at ASC')
        else
          tracks = tracks.where('follows.added_at < ?', rule['value'].days.ago).order('follows.added_at ASC')
        end
      end
    end

    # LABEL
    find_rule(rules, 'label').try do |rule|
      tracks = tracks.joins(:album).where('label ~* ?', rule['value'])
    end

    # RELEASE DATE
    find_rule(rules, 'release_date').try do |rule|
      if rule['operator'] == 'less'
        tracks = tracks.joins(:album).where('release_date >= ?', rule['value'].to_i.days.ago)
      elsif rule['operator'] == 'greater'
        tracks = tracks.joins(:album).where('release_date <= ?', rule['value'].to_i.days.ago)
      elsif rule['operator'] == 'between'
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
    if catalog == 'songs'
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
    if catalog == 'songs'
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
      tracks = tracks.where("key = ?", rule['value'])
    end

    # MODE
    find_rule(rules, 'mode').try do |rule|
      tracks = tracks.where("key = ?", rule['value'])
    end

    # DANCEABILITY
    find_rule(rules, 'danceability').try do |rule|
      if rule['value'].kind_of?(Array)
        case rule['value'][0]
        when 0 # Not at all
          start = 0.0
        when 1 # A little
          start = 0.2
        when 2 # Somewhat
          start = 0.4
        when 3 # Moderately
          start = 0.6
        when 4 # Very
          start = 0.8
        when 5 # Super
          start = 0.9
        end

        case rule['value'][1]
        when 0 # Not at all
          final = 0.199
        when 1 # A little
          final = 0.399
        when 2 # Somewhat
          final = 0.599
        when 3 # Moderately
          final = 0.799
        when 4 # Very
          final = 0.899
        when 5 # Super
          final = 1.0
        end

      else
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
      end
      
      if rule['operator'] == 'less'
        tracks = tracks.where("danceability < ?", final)
      elsif rule['operator'] == 'greater'
        tracks = tracks.where("danceability > ?", start)
      else
        tracks = tracks.where("danceability between ? and ?", start, final)
      end
      
    end

    # ACOUSTICNESS
    find_rule(rules, 'acousticness').try do |rule|
      if rule['value'].kind_of?(Array)
        case rule['value'][0]
        when 0 # Not at all
          start = 0.0
        when 1 # Somewhat
          start = 0.251
        when 2 # Likely
          start = 0.501
        when 3 # Very likely
          start = 0.751
        end

        case rule['value'][1]
        when 0 # Not at all
          final = 0.250
        when 1 # Somewhat
          final = 0.500
        when 2 # Likely
          final = 0.750
        when 3 # Very likely
          final = 1.0
        end
        
      else
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
      end

      if rule['operator'] == 'less'
        tracks = tracks.where("acousticness < ?", final)
      elsif rule['operator'] == 'greater'
        tracks = tracks.where("acousticness > ?", start)
      else
        tracks = tracks.where("acousticness between ? and ?", start, final)
      end

    end

    # ENERGY
    find_rule(rules, 'energy').try do |rule|
      if rule['value'].kind_of?(Array)
        case rule['value'][0]
        when 0 # Not at all
          start = 0.0
        when 1 # Somewhat
          start = 0.251
        when 2 # Somewhat
          start = 0.501
        when 3 # Very
          start = 0.751
        end

        case rule['value'][1]
        when 0 # Not at all
          final = 0.250
        when 1 # Somewhat
          final = 0.500
        when 2 # Somewhat
          final = 0.750
        when 3 # Very
          final = 1.0
        end
      else
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
      end

      if rule['operator'] == 'less'
        tracks = tracks.where("energy < ?", final)
      elsif rule['operator'] == 'greater'
        tracks = tracks.where("energy > ?", start)
      else
        tracks = tracks.where("energy between ? and ?", start, final)
      end
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
      tracks = tracks.where("instrumentalness between ? and ?", start, final)
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
      tracks = tracks.where("speechiness between ? and ?", start, final)
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
      tracks = tracks.where("valence between ? and ?", start, final)
    end

    # POPULARITY
    find_rule(rules, 'popularity').try do |rule|
      if rule['operator'] == 'less'
        tracks = tracks.where("tracks.popularity < ?", rule['value'])
      elsif rule['operator'] == 'greater'
        tracks = tracks.where("tracks.popularity > ?", rule['value'])
      elsif rule['operator'] == 'between'
        tracks = tracks.where("tracks.popularity between ? and ?", rule['value'][0], rule['value'][1])
      end
    end

    # SORT
    if sort.present?
      case sort
      when 'random'
        #tracks = tracks.order("random()")
      when 'most_popular'
        tracks = tracks.order("tracks.popularity DESC")
      when 'least_popular'
        tracks = tracks.order("tracks.popularity ASC")
      when 'most_often_played'
        tracks = tracks.order("follows.plays DESC") if catalog == 'songs'
      when 'least_often_played'
        tracks = tracks.order("follows.plays ASC") if catalog == 'songs'
      when 'most_recently_added'
        tracks = tracks.order("follows.added_at DESC") if catalog == 'songs'
      when 'least_recently_added'
        tracks = tracks.order("follows.added_at ASC") if catalog == 'songs'
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
    # Rules
    rules = filters['rules'].to_a.map { |item| "#{translate_field(item['field'])} #{translate_operator(item['operator'])} #{translate_value(item['field'], item['value'])}" }.join(", ")
    
    # Source
    source = case catalog
    when 'songs'
      "only songs I've liked"
    when 'artists'
      "any songs from artists I've liked"
    when 'full'
      "the full Spotify catalog"
    end

    # Limt & Sorting
    [['Random','random'], ['Most Popular', 'most_popular'], ['Least Popular', 'least_popular'], ['Most Played', 'most_often_played'], ['Least Played', 'least_often_played'], ['Most Recently Added', 'most_recently_added'], ['Least Recently Added', 'least_recently_added'], ['Release Date - Ascending', 'release_date_asc'], ['Release Date - Descending', 'release_date_desc']]

    sorting = case sort
    when 'random'
      "randomly"
    when 'most_popular'
      "by most popular"
    when 'least_popular'
      "by least popular"
    when 'most_often_played'
      "by most often played"
    when 'least_often_played'
      "by least often played"
    when 'most_recently_added'
      "by most recently added"
    when 'least_recently_added'
      "by least recently added"
    when 'release_date_asc'
      "by release date (ascending)"
    when 'release_date_desc'
      "by release date (descending)"
    end

    output = ''
    output << "#{rules}. " if rules.present?
    output << "Uses #{source}. " if source.present?
    output << "Sorted #{sorting}. " if sorting.present?
    output << "Limited to #{limit} songs." if limit.present?

    output
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
    when "begins_with"
      "begins with"
    when "ends_with"
      "ends with"
    else
      operator
    end
  end

  def translate_value(field, value)
    case field
    when "acousticness"
      if value.kind_of?(Array)
        case value[0]
        when 0 # Not at all
          start = "Not at all"
        when 1 # Somewhat
          start = "Somewhat"
        when 2 # Likely
          start = "Likely"
        when 3 # Very likely
          start = "Very likely"
        end

        case value[1]
        when 0 # Not at all
          finish = "Not at all"
        when 1 # Somewhat
          finish = "Somewhat"
        when 2 # Likely
          finish = "Likely"
        when 3 # Very likely
          finish = "Very likely"
        end
        "#{start} and #{finish}"
      else
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
      end
      
    when "danceability"
      if value.kind_of?(Array)
        case value[0]
        when 0 # Not at all
          start = "Not at all"
        when 1 # A little
          start = "A little"
        when 2 # Somewhat
          start = "Somewhat"
        when 3 # Moderately
          start = "Moderately"
        when 4 # Very
          start = "Very"
        when 5 # Super
          start = "Super"
        end
        case value[1]
        when 0 # Not at all
          finish = "Not at all"
        when 1 # A little
          finish = "A little"
        when 2 # Somewhat
          finish = "Somewhat"
        when 3 # Moderately
          finish = "Moderately"
        when 4 # Very
          finish = "Very"
        when 5 # Super
          finish = "Super"
        end
        "#{start} and #{finish}"
      else
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
      if value.kind_of?(Array)
        case value[0]
        when 0 
          start = "Low"
        when 1
          start = "Medium"
        when 2
          start = "High"
        when 3 
          start = "Insane"
        end

        case value[1]
        when 0 
          finish = "Low"
        when 1
          finish = "Medium"
        when 2
          finish = "High"
        when 3 
          finish = "Insane"
        end

        "#{start} and #{finish}"
      else
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
      if value.is_a?(Array)
        if value[0].scan(/\D/).empty? and (1700..2100).include?(value[0].to_i)
          release_date_start = "#{value[0]}-01-01"
        else
          release_date_start = value[0]
        end

        if value[1].scan(/\D/).empty? and (1700..2100).include?(value[1].to_i)
          release_date_end = "#{value[1]}-12-31"
        else
          release_date_end = value[1]
        end

        "#{release_date_start.to_date.strftime("%b %-d, %Y")} and #{release_date_end.to_date.strftime("%b %-d, %Y")}"
      else
        "#{value} days ago"
      end
    when "duration"
      if value.is_a?(Array)
        "#{value[0]} and #{value[1]} seconds"
      else
        value
      end
    when "bpm"
      if value.is_a?(Array)
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