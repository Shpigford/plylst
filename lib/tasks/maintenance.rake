namespace :maintenance do
  desc "Get updated tracks: 0 1 * * *"
  task :get_tracks => :environment do
    GetMoreCategoriesWorker.set(queue: :slow).perform_async
    GetMoreFeaturedWorker.set(queue: :slow).perform_async
    GetMoreNewReleasesWorker.set(queue: :slow).perform_async
    GetMoreArtistsWorker.set(queue: :slow).perform_async
  end

  desc "Pull lyrics: 0 3 * * *"
  task :get_lyrics => :environment do
    Track.where(lyrics: nil).find_each do |track|
      GetLyricsWorker.set(queue: :lyrics).perform_async(track.id) if track.lyrics.blank?
    end
  end

  desc "Update user data regularly: */30 * * * *"
  task :update_data_regular => :environment do
    User.active.find_each do |user|
      UpdatePlayDataWorker.set(queue: :slow).perform_async(user.id)
      BuildUserGenresWorker.set(queue: :slow).perform_async(user.id)
    end
    #ProcessAudioFeaturesWorker.set(queue: :slow).perform_async
  end

  desc "Update user data every 2 hours: 0 */2 * * *"
  task :update_data_2_hours => :environment do
    User.active.find_each do |user|
      RecentlyStreamedWorker.set(queue: :slow).perform_async(user.id)
    end
  end

  desc "Update user data daily: 0 */2 * * *"
  task :update_data_daily => :environment do
    User.active.find_each do |user|
      ProcessAccountWorker.set(queue: :slow).perform_async(user.id)
      BuildPlaylistsWorker.set(queue: :slow).perform_async(user.id)
      CheckTracksWorker.set(queue: :slow).perform_async(user.id)
    end
  end

  desc "Transition JSONB to first-class columns"
  task :transition_jsonb => :environment do
    sql = <<-SQL
      UPDATE tracks
      SET key = ((audio_features->>'key'))::numeric,
      mode = ((audio_features->>'mode'))::numeric,
      tempo = ((audio_features->>'tempo'))::numeric,
      energy = ((audio_features->>'energy'))::numeric,
      valence = ((audio_features->>'valence'))::numeric,
      liveness = ((audio_features->>'liveness'))::numeric,
      loudness = ((audio_features->>'loudness'))::numeric,
      speechiness = ((audio_features->>'speechiness'))::numeric,
      acousticness = ((audio_features->>'acousticness'))::numeric,
      danceability = ((audio_features->>'danceability'))::numeric,
      time_signature = ((audio_features->>'time_signature'))::numeric,
      instrumentalness = ((audio_features->>'instrumentalness'))::numeric;
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end
end