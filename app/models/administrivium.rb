class Administrivium
  include Mongoid::Document
  include Mongoid::Timestamps
  field :keyword,type: String
  field :total,type:Integer
  field :avg,type:Float
  field :title, type: String
  field :link, type: String
  field :media, type: String
  field :date,type: String
  field :month,type: String
  field :day,type: String
  field :hour, type: String
  field :relay,type:Integer
  field :descript,type:String
  field :medias,type:Array
  field :start_date,type: String
  field :end_date,type: String

  def after_create
    unless self.end_date.present?
      self.end_date = (Date.today - 1.days).strftime('%F')
      self.save
    end
  end
end