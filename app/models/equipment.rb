class Equipment < ActiveRecord::Base
  belongs_to :meter

  default_scope -> { order(:created_at => :desc) }
end
