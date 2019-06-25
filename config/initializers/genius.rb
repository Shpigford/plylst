if ENV['genius']
  Genius.access_token = ENV['genius']
else
  puts "! please add `genius` to your config/application.yml file to enable Genius/lyric support".yellow
end