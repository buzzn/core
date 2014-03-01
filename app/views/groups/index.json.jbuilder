json.array!(@groups) do |group|
  json.extract! group, :id, :name, :private, :type
  json.url group_url(group, format: :json)
end
