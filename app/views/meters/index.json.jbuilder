json.array!(@meters) do |meter|
  json.extract! meter, :id, :name, :uid, :private, :type, :user_id
  json.url meter_url(meter, format: :json)
end
