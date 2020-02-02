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
end