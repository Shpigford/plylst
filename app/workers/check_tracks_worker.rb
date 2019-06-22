class CheckTracksWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id

    if user.active?
      track_ids = user.tracks.where('follows.active = ?', true).pluck(:spotify_id)

      track_ids.each_slice(50) do |slice|
        RemoveTracksWorker.perform_async(user_id, slice)
      end
    end
  end
end
