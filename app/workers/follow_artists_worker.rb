class FollowArtistsWorker
  include Sidekiq::Worker

  def perform(user_id, artist_ids)
    # Do something
  end
end
