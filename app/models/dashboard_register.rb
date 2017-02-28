class DashboardRegister < ActiveRecord::Base
  belongs_to :dashboard
  belongs_to :register, class_name: Register::Base, foreign_key: :register_id
end
