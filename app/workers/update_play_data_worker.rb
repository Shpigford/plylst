class UpdatePlayDataWorker
  include Sidekiq::Worker

  def perform
    User.all.each do |user|
      user.follows.each do |follow|
        if follow.streams.present?
          follow.plays = follow.streams.count
          follow.last_played_at = follow.streams.order('played_at DESC').first.played_at
          follow.save
        end
      end
    end
  end
end

# Sidekiq::Cron::Job.create(name: 'Play Data', cron: '*/45 * * * *', class: 'UpdatePlayDataWorker')