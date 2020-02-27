cache('sitemap-playlists', expires_in: 24.hours) do
  base_url = "https://plylst.app/"

  xml.instruct! :xml, :version=>"1.0"
  xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9', 'xmlns:image' => 'http://www.google.com/schemas/sitemap-image/1.1', 'xmlns:video' => 'http://www.google.com/schemas/sitemap-video/1.1' do
    Playlist.where(public: true).find_each do |playlist|
      xml.url do
        xml.loc playlist_url(playlist)
        xml.lastmod playlist.updated_at.iso8601
        xml.changefreq 'daily'
      end
    end
  end
end