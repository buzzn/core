
PublicActivity::Activity.class_eval do
  acts_as_commentable
  acts_as_votable
end
