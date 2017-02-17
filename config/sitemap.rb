# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = Rails.application.secrets.hostname

SitemapGenerator::Sitemap.create do
  Group::Base.readable_by_world.each do |group|
    add group_path(group), :lastmod => group.updated_at
  end
end
SitemapGenerator::Sitemap.ping_search_engines # Not needed if you use the rake tasks
