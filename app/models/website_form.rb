class WebsiteForm < ActiveRecord::Base

  scope :permitted, ->(uids) { where(nil) }

  enum form_name: { powertaker_v1: 'powertaker_v1' }

end
