class UpdatePlayDataWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id

    if user.active?
      user.follows.find_each do |follow|
        if follow.streams.exists?
          follow.plays = follow.streams.count
          follow.last_played_at = follow.streams.maximum(:played_at)
          follow.save
        end
      end
    end
  end
end