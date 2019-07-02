class UserDataUpdateWorker
  include Sidekiq::Worker

  def perform(frequency = 'hourly')
    User.active.find_each do |user|

      if frequency == 'hourly'
        UpdatePlayDataWorker.perform_async(user.id)
        RecentlyStreamedWorker.perform_async(user.id)
        BuildUserGenresWorker.perform_async(user.id)
      end

      if frequency == 'daily'
        ProcessAccountWorker.perform_async(user.id)
        BuildPlaylistsWorker.perform_async(user.id)
        CheckTracksWorker.perform_async(user.id)
        #GetMoreTracksWorker.perform_async

        # Track.where(lyrics: nil).find_each do |track|
        #   Track.with_advisory_lock("#{track.id}") do
        #     GetLyricsWorker.perform_async(track.id)
        #   end
        # end
      end
    end
  end
end


# Sidekiq::Cron::Job.create(name: 'Update User Data: Regularly', cron: '*/30 * * * *', class: 'UserDataUpdateWorker', args: ['hourly'])

# Sidekiq::Cron::Job.create(name: 'Update User Data: Daily', cron: '0 18 * * *', class: 'UserDataUpdateWorker', args: ['daily'])