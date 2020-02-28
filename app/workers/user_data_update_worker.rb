class UserDataUpdateWorker
  include Sidekiq::Worker

  sidekiq_options lock: :while_executing

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
      end
    end
  end
end


# Sidekiq::Cron::Job.create(name: 'Update User Data: Regularly', cron: '*/30 * * * *', class: 'UserDataUpdateWorker', args: ['hourly'])

# Sidekiq::Cron::Job.create(name: 'Update User Data: Daily', cron: '0 */2 * * *', class: 'UserDataUpdateWorker', args: ['daily'])