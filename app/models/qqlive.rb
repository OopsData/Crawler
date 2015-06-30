require 'movie_spider'
class Qqlive
  include Mongoid::Document
  include Mongoid::Timestamps
  field :cmt_id, type: String
  field :last_id,type: String
  field :target,type: String
  field :up,type: String
  field :rep,type: String
  field :time,type: DateTime
  field :cont, type: String
  field :nick,type: String
  field :gender,type: Integer
  field :region,type:String
  index({ time: 1 }, { background: true } )
end