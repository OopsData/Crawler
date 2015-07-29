class TiebaTheme
  include Mongoid::Document
  include Mongoid::Timestamps	

  field :name,type:String #贴吧名称
  field :tid,type:String # 主题id
  field :title,type:String # 主题标题
  field :content,type:String # 主题内容
  field :author,type:Hash # 作者信息
  field :date,type:String # 主题发表日期
  field :reply,type:Integer # 主题回帖数

  has_many :tieba_posts
  has_many :posts, class_name: "TiebaPost"

  index({ name: 1 }, { background: true } )
  index({ title: 1 }, { background: true } )
  index({ tid: 1 }, { background: true } )
  index({ date: 1 }, { background: true } )

  def self.save_history_data(name,res)
  	res.each do |tid,data|
      begin 
        theme = self.where(tid:tid).first
        param = {name:name,tid:tid,title:data[:basic][:title],content:data[:basic][:content],author:data[:basic][:author],date:data[:basic][:date],reply:data[:basic][:reply].to_i}
        unless theme.present?
          theme = self.create(param)
        else
          theme.update_attributes(param)
        end
        if data[:posts]
          TiebaPost.save_post_data(theme.id.to_s,data[:posts])
        end
      rescue
        next
      end
  	end
  end

end

