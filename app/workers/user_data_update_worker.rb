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
      end
    end
  end
end


# Sidekiq::Cron::Job.create(name: 'Update User Data', cron: '*/30 * * * *', class: 'UserDataUpdateWorker')