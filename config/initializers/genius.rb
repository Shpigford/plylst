if ENV['genius_access_token']
  Genius.access_token = ENV['genius_access_token']
else
  puts "! please add `genius_access_token` to your config/application.yml file to enable Genius/lyric support".yellow
end