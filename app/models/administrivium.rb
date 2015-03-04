class Administrivium
  include Mongoid::Document
  include Mongoid::Timestamps
  field :keyword,type: String
  field :title, type: String
  field :link, type: String
  field :time, type: String
  field :emotion,type: String
  field :start_date,type: String
  field :end_date,type: String
  field :num, type: Integer
  field :media, type: String
  field :reps, type: Array
  field :summary, type: String
end
