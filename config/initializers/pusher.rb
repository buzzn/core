Pusher.app_id = Rails.application.secrets.pusher_app_id
Pusher.key    = Rails.application.secrets.pusher_key
Pusher.secret = Rails.application.secrets.pusher_secret
Pusher.host   = Rails.application.secrets.pusher_host if Rails.application.secrets.pusher_host # user pusher.com if no slanger host exists
Pusher.port   = Rails.application.secrets.pusher_port if Rails.application.secrets.pusher_port
