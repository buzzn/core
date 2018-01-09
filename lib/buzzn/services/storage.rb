require_relative '../services'

class Services::Storage
  include Import['config.fog']

  def create
    storage = Fog::Storage.new(fog[:storage_opts])
    storage.directories.new(fog[:directory_opts])
  end

  # just factory method for Fog::Storage
  def self.new
    @instance ||= super().create
  end

end
