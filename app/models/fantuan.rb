require 'movie_spider'
class Fantuan
  include Mongoid::Document
  include Mongoid::Timestamps
  field :postid,type:String
  field :title,type:String
  field :content,type:String
  field :orireplynum,type:Integer
  field :up,type:Integer
  field :author,type:String
  field :gender,type:Integer
  field :region,type:String
  field :time,type:DateTime
  field :comments,type:Array

  index({ title: 1 }, { background: true } )
  index({ postid: 1 }, { background: true } )

end