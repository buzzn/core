class CommentResource < Buzzn::BaseResource

  model Comment

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

# TODO get rid of the need of having a Serializer class
class CommentSerializer < CommentResource
  def self.new(*args)
    super
  end
end
