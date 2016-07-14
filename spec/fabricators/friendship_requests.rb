Fabricator :friendship_request do
  sender    { |attrs| attrs[:sender] }
  receiver  { |attrs| attrs[:receiver] }
end

Fabricator :friendship_request_with_activity, from: :friendship_request do
  after_create do |request|
    Fabricate(:activity, { key: 'friendship_request.create', owner: request.sender, recipient: request.receiver })
  end
end
