class UserDataUpdateWorker
  include Sidekiq::Worker

  def perform
    User.active.find_each do |user|
      UpdatePlayDataWorker.perform_async(user.id)
      RecentlyStreamedWorker.perform_async(user.id)
      BuildUserGenresWorker.perform_async(user.id)
    end
  end
end


# Sidekiq::Cron::Job.create(name: 'Update User Data', cron: '*/30 * * * *', class: 'UserDataUpdateWorker')