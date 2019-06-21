class BuildUserGenresWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id

    if user.active? and user.artists.present?
      genres = user.artists.pluck(:genres).flatten!.uniq.delete_if { |k| k.blank? }.sort
      user.update_attribute(:genres, genres)
    end
  end
end
