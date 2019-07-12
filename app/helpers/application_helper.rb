module ApplicationHelper
  def gravatar_url(email, size)
    gravatar = Digest::MD5::hexdigest(email).downcase
    url = "https://gravatar.com/avatar/#{gravatar}.png?s=#{size}"
  end

  def format_ms(duration)
    Time.at(duration/1000).utc.strftime("%-M:%S")
  end

  def human_readable(variable_hash)
    filter_map = {
      "lt" => "Less than",
      "gt" => "Greater than",
    }

    musical_key_map = {
      0 => "C",
      1 => "C♯, D♭",
      2 => "D",
      3 => "D♯, E♭",
      4 => "E",
      5 => "F",
      6 => "F♯, G♭",
      7 => "G",
      8 => "G♯, A♭",
      9 => "A",
      10 => "A♯, B♭",
      11 => "B",
    }

    mode_map = {
      0 => "Minor",
      1 => "Major",
    }

    energy_map = {
      0 => "Low",
      1 => "Medium",
      2 => "High",
      3 => "Insane",
    }

    acoustic_map = {
      0 => "Not at all",
      1 => "Somewhat",
      2 => "Likely",
      3 => "Very Likely",
    }

    valence_map = {
      0 => "Negative",
      1 => "Positive"
    }

    speech_map = {
      0 => "No",
      1 => "Yes",
    }

    instrumentalness_map = {
      0 => "No",
      1 => "Yes",
    }

    danceability_map = {
      0 => "Not at all",
      1 => "A little",
      2 => "Somewhat",
      3 => "Moderately",
      4 => "Very",
      5 => "Super",
    }

    output = variable_hash.delete_if{|k| k == 'liveness' || k == 'loudness' || k == 'speechiness' || k == 'time_signature' }.delete_if { |k, v| v.blank? }.map do |key, value| 
      label = "#{key.split('_').map(&:capitalize).join(' ').gsub('Tempo', 'BPM').gsub('Instrumentalness', 'Instrumental').gsub('Tempo', 'BPM').gsub('Valence', 'Mood')}"
      formatted_value = case key
      when "key" then musical_key_map.fetch(value)
      when "mode" then mode_map.fetch(value)
      when "tempo" then value.to_i
      when "energy" then energy_map.fetch(energy_value(value))
      when "valence" then valence_map.fetch(valence_value(value))
      when "speechiness" then speech_map.fetch(speech_value(value))
      when "acousticness" then acoustic_map.fetch(acoustic_value(value))
      when "danceability" then danceability_map.fetch(danceability_value(value))
      when "instrumentalness" then instrumentalness_map.fetch(instrumentalness_value(value))
      end
      "<b>#{label}:</b> #{formatted_value}" 
    end.join(' - ')

    if output.blank?
      output = "No variables set"
    else
      output
    end
  end

  def energy_value(value)
    case value
    when 0.0..0.250 then 0
    when 0.251..0.500 then 1
    when 0.501..0.750 then 2
    when 0.751..1.0 then 3
    end
  end

  def acoustic_value(value)
    case value
    when 0.0..0.250 then 0
    when 0.251..0.500 then 1
    when 0.501..0.750 then 2
    when 0.751..1.0 then 3
    end
  end

  def danceability_value(value)
    case value
    when 0.0..0.199 then 0
    when 0.2..0.399 then 1
    when 0.4..0.599 then 2
    when 0.6..0.799 then 3
    when 0.8..0.899 then 4
    when 0.9..1.0 then 5
    end
  end

  def valence_value(value)
    case value
    when 0.0..0.5 then 0
    when 0.501..1.0 then 1
    end
  end

  def instrumentalness_value(value)
    case value
    when 0.0..0.799 then 0
    when 0.8..1.0 then 1
    end
  end

  def speech_value(value)
    case value
    when 0.0..0.66 then 0
    when 0.667..1.0 then 1
    end
  end
end
