require 'buzzn/serializable_resource'
require 'buzzn/resource/base'

# FIXME just make this right resources vs. serializers
# workaround and preload serializer as they are in the wrong place right now
Buzzn::Application.config.paths['app'].dup.tap do |app|
  app.glob = 'resources/**/*.rb'
  app.to_a.each { |path| require path }
end
