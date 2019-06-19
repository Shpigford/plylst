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

    danceability_map = {
      0 => "Not at all",
      1 => "A little",
      2 => "Somewhat",
      3 => "Moderately",
      4 => "Very",
      5 => "Super",
    }

    output = variable_hash.delete_if { |k, v| v.blank? }.map do |key, value| 
      label = "#{key.split('_').map(&:capitalize).join(' ')}"
      formatted_value = case key
      when "days_ago_filter", "plays_filter", "bpm_filter", "duration_filter" then filter_map.fetch(value)
      when "key" then musical_key_map.fetch(value)
      when "danceability" then danceability_map.fetch(value)
      else value.to_s.split('_').map(&:capitalize).join(' ')
      end
      "#{label}: #{formatted_value}" 
    end.join(' - ')

    if output.blank?
      output = "No variables set"
    else
      output
    end
  end
end
