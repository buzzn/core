class Comment < ActiveRecord::Base
  include Filterable

  acts_as_nested_set :scope => [:commentable_id, :commentable_type]

  validates :body, :presence => true
  validates :user, :presence => true

  before_destroy :destroy_children

  mount_uploader :image, PictureUploader

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  acts_as_votable

  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  validate :validate_invariants

  def validate_invariants
    errors.add(:commentable, "must have superclass ActiveRecord::Base: #{self.commentable_type}") unless self.commentable_type.constantize.superclass == ActiveRecord::Base
  end

  def self.filter(search)
    do_filter(search, :title, :subject, :body)
  end

  #helper method to check if a comment has children
  def has_children?
    self.children.any?
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:user_id => user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  private
    def destroy_children
      self.children.each{|comment| comment.destroy}
    end

end
