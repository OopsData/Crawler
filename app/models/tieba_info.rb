class TiebaInfo
  include Mongoid::Document
  include Mongoid::Timestamps	

  field :name,type:String #贴吧名称
  field :tid,type:String # 主题id
  field :basic,type:Hash # 主题帖基本信息
  field :posts,type:Array # 主题帖子的回贴信息及回帖的评论信息

  index({ name: 1 }, { background: true } )
  index({ tid: 1 }, { background: true } )

  def self.save_history_data(name,res)
  	res.each do |tid,data|
  		theme = self.where(tid:tid).first
  		data.merge!({name:name,tid:tid})
  		begin
  			unless theme.present?
  				self.create(data)
  			else
  				theme.update_attributes(data)
  			end
  		rescue
  			puts '==============更新或存储数据时候出错,出错信息如下:=============='
  			puts "error:#{$!} at:#{$@}"
  			puts '--------------数据信息如下----------------'
  			puts data.inspect
  			puts '==============更新或存储数据时候出错,出错信息如上 =============='
  		end
  	end
  end

end




