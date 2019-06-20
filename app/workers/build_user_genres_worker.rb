class BuildUserGenresWorker
  include Sidekiq::Worker

  def perform(user_id)
    # Do something
  end
end
