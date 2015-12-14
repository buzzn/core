# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.buzzn.net"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  group :staging do
    SitemapGenerator::Sitemap.default_host = 'https://staging.buzzn.net'
  end

  group :production do
    SitemapGenerator::Sitemap.default_host = 'http://www.buzzn.net'
  end

  SitemapGenerator::Sitemap.create do
    Group.find_each do |group|
      add group_path(group), :lastmod => group.updated_at
    end
  end
  SitemapGenerator::Sitemap.ping_search_engines # Not needed if you use the rake tasks
end
