module ApplicationHelper
  def gravatar_url(email, size)
    gravatar = Digest::MD5::hexdigest(email).downcase
    url = "https://gravatar.com/avatar/#{gravatar}.png?s=#{size}"
  end

  def format_ms(duration)
    Time.at(duration/1000).utc.strftime("%-M:%S")
  end
end
