json.array!(@administrivia) do |administrivium|
  json.extract! administrivium, :id, :title, :num, :media, :reps, :summary
  json.url administrivium_url(administrivium, format: :json)
end
