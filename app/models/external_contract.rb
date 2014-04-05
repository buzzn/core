class ExternalContract < ActiveRecord::Base
  belongs_to :external_contractable, polymorphic: true
end
