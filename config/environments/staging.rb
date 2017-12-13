raise <<-EOS
  RAILS_ENV=staging was removed, use production for all deployments. Configure the differences
  with env variables instead. See https://12factor.net/config for details
  and reasoning."
EOS
