class BuildUserGenresWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id

    if user.active?
      genres = user.artists.pluck(:genres).flatten!.uniq.sort
      user.update_attribute(:genres, genres)
    end


  end
end
