if Import.global?('config.aws_secret_key')
  Aws.config.update(
    {
      region: Import.global('config.aws_region'),
      credentials: Aws::Credentials.new(Import.global('config.aws_access_key'),
                                        Import.global('config.aws_secret_key'))
    }
  )
end
