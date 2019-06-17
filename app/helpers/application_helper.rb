module ApplicationHelper
  def gravatar_url(email, size)
    gravatar = Digest::MD5::hexdigest(email).downcase
    url = "https://gravatar.com/avatar/#{gravatar}.png?s=#{size}"
  end

  def format_ms(duration)
    Time.at(duration/1000).utc.strftime("%-M:%S")
  end

  def human_readable(variable_hash)
    output = variable_hash.delete_if { |k, v| v.blank? }.map {|k,v| "#{k.split('_').map(&:capitalize).join(' ')}: #{v.to_s.split('_').map(&:capitalize).join(' ')}"}.join(' - ')

    if output.blank?
      output = "No variables set"
    else
      output
    end
  end
end
