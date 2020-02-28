class UpdatePlayDataWorker
  include Sidekiq::Worker

  sidekiq_options lock: :while_executing

  def perform(user_id)
    user = User.find user_id

    if user.active?
      ActiveRecord::Base.connection.exec_query("UPDATE follows 
        SET plays = s.plays, last_played_at = s.last 
        FROM (
          SELECT 
            track_id, 
            count(1) as plays, 
            max(played_at) as last 
          FROM streams 
          WHERE user_id = #{user.id}
          GROUP BY track_id
        ) s 
        WHERE s.track_id = follows.track_id 
          AND follows.user_id = #{user.id}")
    end
  end
end