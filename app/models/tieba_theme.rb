class TiebaTheme
  include Mongoid::Document
  include Mongoid::Timestamps	

  field :name,type:String #贴吧名称
  field :tid,type:String # 主题id
  field :title,type:String # 主题标题
  field :content,type:String # 主题内容
  field :author,type:Hash # 作者信息
  field :date,type:String # 主题发表日期
  field :reply,type:String # 主题回帖数

  has_many :tieba_posts

  index({ name: 1 }, { background: true } )
  index({ tid: 1 }, { background: true } )
  index({ date: 1 }, { background: true } )

  def self.save_history_data(name,res)
  	res.each do |tid,data|
  		theme = self.where(tid:tid).first
      param = {name:name,tid:tid,title:data['title'],content:data['content'],author:data['author'],date:data['date'],reply:data['reply']}
      unless theme.present?
        theme = self.create(param)
      else
        theme.update_attributes(param)
      end

      TiebaPost.save_post_data(theme.id.to_s,data['posts'])

      if data['posts'].length > 0
        data['posts'].each do |post|
          po = TiebaPost.where(post_id:post['id']).first 
          unless po.present?
            
          else
          
          end
        end
      end



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

