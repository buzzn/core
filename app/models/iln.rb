class Iln < ActiveRecord::Base
  belongs_to :organization

  default_scope -> { order(:created_at => :desc) }
end
