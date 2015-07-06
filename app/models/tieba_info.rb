class TiebaInfo
  include Mongoid::Document
  include Mongoid::Timestamps	

  field :name,type:String #贴吧名称
  field :focus,type:Integer # 贴吧的累计关注数
  field :results,type:Hash
end




