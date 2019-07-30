require 'buzzn/boot/main_container'

begin
  fog =
    if Import.global?('config.aws_secret_key')
      require 'fog/aws'
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
      require 'fog/local'
      {
        storage_opts: { provider: 'Local', local_root: 'tmp' },
        directory_opts: { key: 'files' }
      }
    end
  Buzzn::Boot::MainContainer.register_config(:fog, fog)
  Buzzn::Boot::MainContainer.register_config(:templates_path, 'app/pdfs')
end
