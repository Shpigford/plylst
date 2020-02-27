cache('sitemap-pages', expires_in: 12.hours) do
  base_url = "https://plylst.app/"

  xml.instruct! :xml, :version=>"1.0"
  xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9', 'xmlns:image' => 'http://www.google.com/schemas/sitemap-image/1.1', 'xmlns:video' => 'http://www.google.com/schemas/sitemap-video/1.1' do
    xml.url do
      xml.loc base_url
    end

    xml.url do
      xml.loc most_listened_tracks_labs_url
      xml.changefreq 'daily'
    end

    xml.url do
      xml.loc genres_url
      xml.changefreq 'daily'
    end
  end
end