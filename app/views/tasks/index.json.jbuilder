json.array!(@tasks) do |task|
  json.extract! task, :id, :title, :url, :site, :status
  json.url task_url(task, format: :json)
end
