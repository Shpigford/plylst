namespace :maintenance do
  desc "Get updated tracks: 0 1 * * *"
  task :get_tracks => :environment do
    GetMoreCategoriesWorker.set(queue: :slow).perform_async
    GetMoreFeaturedWorker.set(queue: :slow).perform_async
    GetMoreNewReleasesWorker.set(queue: :slow).perform_async
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
    end
    ProcessAudioFeaturesWorker.set(queue: :slow).perform_async
  end

  desc "Update user data every 2 hours: 0 */2 * * *"
  task :update_data_2_hours => :environment do
    # Only process a set % of oldest processed accounts
    total_users = User.active.count
    limit = (0.15 * total_users).ceil
    users = User.active.order('last_processed_at ASC NULLS FIRST').limit(limit)

    users.find_each do |user|
      ProcessAccountWorker.perform_async(user.id)
      BuildPlaylistsWorker.set(queue: :default).perform_async(user.id)
      #CheckTracksWorker.set(queue: :slow).perform_async(user.id)
    end
  end

  desc "Update data daily"
  task :update_data_daily => :environment do
    UpdateArtistDataWorker.set(queue: :slow).perform_async
    UpdateAlbumDataWorker.set(queue: :slow).perform_async
  end

  desc "Purge inactive accounts"
  task :purge_inactive => :environment do
    User.active.where('last_sign_in_at < ?', Time.now - 3.months).each do |user|
      playlists = user.playlists.count

      user.update_attribute(:active, false) if playlists == 0
    end
  end

  desc "Transition JSONB to first-class columns"
  task :transition_jsonb => :environment do
      Track.where(key: nil).where.not(audio_features: {}).find_each do |track|
        track.update_attributes(
          key: track.audio_features['key'],
          mode: track.audio_features['mode'],
          tempo: track.audio_features['tempo'],
          energy: track.audio_features['energy'],
          valence: track.audio_features['valence'],
          liveness: track.audio_features['liveness'],
          loudness: track.audio_features['loudness'],
          speechiness: track.audio_features['speechiness'],
          acousticness: track.audio_features['acousticness'],
          danceability: track.audio_features['danceability'],
          time_signature: track.audio_features['time_signature'],
          instrumentalness: track.audio_features['instrumentalness'],
        )
        puts "#{track.id} updated"
      end
  end
  
  desc "Transition catalog column"
  task :transition_catalog => :environment do
    Playlist.all.each do |playlist|
      catalog = playlist.full_catalog.present? ? 'full' : 'songs'
      playlist.update_attribute(:catalog, catalog)
    end
  end
end