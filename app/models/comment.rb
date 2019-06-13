class Comment < ActiveRecord::Base

  self.table_name = :comments

  has_and_belongs_to_many :contracts, class_name: 'Contract::Base'
  has_and_belongs_to_many :groups, class_name: 'Group::Base'

end
