require_relative '../services'

class Services::Storage

  # just factory method for Fog::Storage
  def self.new
    @instance ||= super().create
  end

  def create
    storage = Fog::Storage.new(fog[:storage_opts])
    storage.directories.new(fog[:directory_opts])
  end

  private

  def logger
    @logger ||= Buzzn::Logger.new(self)
  end

  def fog
    @fog ||=
      if Import.global?('config.aws_access_key')
        logger.info('configured AWS fog storage')
        {
          storage_opts: {
            provider: 'AWS',
            aws_access_key_id: Import.global('config.aws_access_key'),
            aws_secret_access_key: Import.global('config.aws_secret_key'),
            region: Import.global('config.aws_region')
          },
          directory_opts: {
            key: Import.global('config.aws_bucket'),
            public: false
          }
        }
      else
        logger.info('configured LOCAL fog storage')
        {
          storage_opts: { provider: 'Local', local_root: 'tmp' },
          directory_opts: { key: 'files' }
        }
      end
  end

end
