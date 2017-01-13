class CommentResource < ApplicationResource

  attributes  :title,
              :body,
              :subject,
              :user_id,
              :created_at,
              :likes,
              :parent_id,
              :image

  has_many :comments

end
