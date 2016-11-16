class DashboardRegister < ActiveRecord::Base
  belongs_to :dashboard
  belongs_to :register
end
