class CommentSerializer < ActiveModel::Serializer

  attributes  :title,
              :body,
              :subject,
              :user_id,
              :created_at,
              :likes,
              :parent_id,
              :image

# TODO when needed we need to make sure we have some method 'comments'
#  has_many :comments

end
