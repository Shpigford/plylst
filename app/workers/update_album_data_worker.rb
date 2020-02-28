class UpdateAlbumDataWorker
  include Sidekiq::Worker

  sidekiq_options queue: :slow, lock: :while_executing

  def perform
    albums_to_update = []

    Album.all.find_each do |album|
      popularity = album.popularity.to_i
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

      albums_to_update << album.id if album.last_checked_at.blank? || album.last_checked_at < days.day.ago
    end

    albums_to_update.in_groups_of(20, false).each do |group|
      GetUpdatedAlbumsDataWorker.set(queue: :slow).perform_async(group)
    end
  end
end
