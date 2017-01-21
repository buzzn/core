Fabricator :activity, from: 'PublicActivity::Activity' do
  key       { |attrs| attrs[:key] }
  owner     { |attrs| attrs[:owner] }
  recipient { |attrs| attrs[:recipient] }
  created_at  { (rand*10).days.ago }
end
