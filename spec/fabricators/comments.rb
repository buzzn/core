Fabricator :comment do
  commentable_id    { |attrs| attrs[:commentable_id] || '' }
  commentable_type  { |attrs| attrs[:commentable_type] || '' }
  user_id           { |attrs| attrs[:user_id] || Fabricate(:user).id }
  parent_id         { |attrs| attrs[:parent_id] || '' }
  body              { FFaker::Lorem.paragraphs.join('-') }
  title             { FFaker::Lorem.sentence }
  subject           { FFaker::Lorem.sentence }
end
