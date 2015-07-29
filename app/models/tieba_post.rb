class TiebaPost
  include Mongoid::Document
  include Mongoid::Timestamps
  field :post_id,type:String
  field :author,type:String  
  field :content,type:String  
  field :date,type:String

  index({ post_id: 1 }, { background: true } )
  index({ date: 1 }, { background: true } )
  index({ tieba_theme_id: 1 }, { background: true } )

  belongs_to :tieba_theme,class_name: "TiebaTheme",inverse_of: :tieba_theme 
  has_many :comments, class_name: "TiebaPostComment"
  def self.save_post_data(theme_id,posts)
  	if posts.length > 0 
  		posts.each do |post|
        begin
          po    = TiebaPost.where(post_id:post[:post_id]).first
          param = {tieba_theme_id:theme_id,post_id:post[:post_id],author:post[:author],content:post[:content],date:post[:date]}
          unless po.present?
            po = self.create(param)
          else
            po.update_attributes(param)
          end
          if post[:comments] 
            TiebaPostComment.save_comment_data(po.id.to_s,post[:comments])
          end         
        rescue
          next
        end
  		end
  	end
  end
end