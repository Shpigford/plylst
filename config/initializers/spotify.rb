if ENV['spotify_key'] || ENV['spotify_secret']
  RSpotify.authenticate(ENV['spotify_key'], ENV['spotify_secret'])
else
  puts "! please add `spotify_key` and `spotify_secret` to your config/application.yml file to enable Spotify support".yellow
end