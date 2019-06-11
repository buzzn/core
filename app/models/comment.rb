class Comment < ActiveRecord::Base

  self.table_name = :comments

  has_and_belongs_to_many :contracts, class_name: 'Contract::Base'

end
