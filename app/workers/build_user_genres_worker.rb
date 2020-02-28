class BuildUserGenresWorker
  include Sidekiq::Worker

  sidekiq_options lock: :while_executing, on_conflict: :reject

  def perform(user_id)
    user = User.find user_id

    if user.active? and user.artists.present?
      genres = user.artists.pluck(:genres).flatten!.uniq.delete_if { |k| k.blank? }.sort
      user.update_attribute(:genres, genres)
    end
  end
end
