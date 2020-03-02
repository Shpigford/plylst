class CreateMetaImageWorker
  include Sidekiq::Worker

  sidekiq_options lock: :while_executing, on_conflict: :reject

  def perform(playlist)
    playlist = Playlist.find_by(id: playlist)

    if playlist.present?
      tracks = playlist.filtered_tracks(playlist.user).pluck(:album_id).uniq.sample(6)
      album_images = Album.where(id: tracks).pluck(:image)

      # Retrieve your user id and api key from the Dashboard
      auth = { username: ENV['hcti_user'], password: ENV['hcti_key'] }

      html = '<div class="box"> <div class="logo"><img src="https://plylst-assets.s3.us-east-1.amazonaws.com/images/plylst-logo.png"></div><div class="images">'
      
      album_images.each do |image|
        html += "<img src='#{image}'>"
      end

      html += '</div></div>'

      css = ".box{padding:0;margin:0;color:#fff;font-size:0;width:720px;height:480px;position:relative}.box .logo{background:#fff;z-index:100;padding:20px 0;text-align:center;width:100%;margin:0 auto;top:190px;position:absolute}.box .logo img{width:30%}.box .images img{width:33.333%;margin:0;padding:0}"

      image = HTTParty.post("https://hcti.io/v1/image",
                          body: { html: html, css: css },
                          basic_auth: auth)

      playlist.update_columns(meta_image: image.parsed_response['url'])
    end
  end
end
