json.array!(@movies) do |movie|
  json.extract! movie, :id, :title, :url, :site, :comment_count, :up_count, :down_count, :status
  json.url movie_url(movie, format: :json)
end
