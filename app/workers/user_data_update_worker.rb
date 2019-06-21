class UserDataUpdateWorker
  include Sidekiq::Worker

  def perform
    User.active.find_each do |user|
      UpdatePlayDataWorker.perform_async(user.id)
      RecentlyStreamedWorker.perform_async(user.id)
      BuildUserGenresWorker.perform_async(user.id)
      ProcessAccountWorker.perform_async(user.id) if user.updated_at < 1.day.ago
      
      user.touch
    end
  end
end


# Sidekiq::Cron::Job.create(name: 'Update User Data', cron: '*/30 * * * *', class: 'UserDataUpdateWorker')