require 'buzzn/boot/main_container'

begin
  fog =
    if ENV.key?('AWS_ACCESS_KEY')
      require 'fog/aws'
      { storage_opts: { provider: 'AWS', aws_access_key_id: ENV['AWS_ACCESS_KEY'], aws_secret_access_key: ENV['AWS_SECRET_KEY'], region: ENV['AWS_REGION'] },
        directory_opts: { key: ENV['AWS_BUCKET'], public: false } }
    else
      require 'fog/local'
      { storage_opts: { provider: 'Local', local_root: 'tmp' },
        directory_opts: { key: 'files' } }
    end
  Buzzn::Boot::MainContainer.register_config(:fog, fog)
  Buzzn::Boot::MainContainer.register_config(:templates_path, 'app/pdfs')
end
