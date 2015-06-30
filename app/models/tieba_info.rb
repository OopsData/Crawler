class TiebaInfo
  include Mongoid::Document
  include Mongoid::Timestamps	

  field :star, type: String
  field :created,type: String
  field :date,type:String
  field :author,type: String
  field :actor,type: String
  field :title,type: String
  field :content,type: String
  field :comment,type:Integer
  field :reply,type: Integer
  field :focus, type: Integer
end