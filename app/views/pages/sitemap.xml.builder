cache('sitemap', expires_in: 12.hours) do
  base_url = "https://plylst.app/"

  xml.instruct! :xml, :version=>"1.0"
  xml.tag! 'sitemapindex', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
    xml.sitemap do
      xml.loc sitemap_pages_url
    end

    xml.sitemap do
      xml.loc sitemap_playlists_url
    end
  end
end