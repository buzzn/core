if ENV.key?('AWS_ACCESS_KEY')
  Aws.config.update(
    {
      region: ENV['AWS_REGION'],
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])
    }
  )
end
