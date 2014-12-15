class Area < ActiveRecord::Base
  belongs_to :group

  default_scope -> { order(:created_at => :desc) }
end
