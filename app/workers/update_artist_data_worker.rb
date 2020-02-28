class UpdateArtistDataWorker
  include Sidekiq::Worker

  sidekiq_options queue: :slow, lock: :while_executing

  def perform
    artists_to_update = []

    Artist.all.find_each do |artist|
      popularity = artist.popularity.to_i
      case
        when popularity < 25
          days = 90
        when popularity < 50
          days = 60
        when popularity < 80
          days = 30
        else
          days = 7
      end

      artists_to_update << artist.id if artist.last_checked_at.blank? || artist.last_checked_at < days.day.ago
    end

    artists_to_update.in_groups_of(50, false).each do |group|
      GetUpdatedArtistsDataWorker.set(queue: :slow).perform_async(group)
    end
  end
end
