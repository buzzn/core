ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id     => Rails.application.secrets.aws_access_key,
  :secret_access_key => Rails.application.secrets.aws_secret_access_key