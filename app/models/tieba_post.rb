class TiebaPost
  include Mongoid::Document
  include Mongoid::Timestamps
  field :post_id,type:String
  field :author,type:String  
  field :content,type:String  
  field :date,type:String
  belongs_to :tieba_theme	
  has_many :tieba_post_comments
  def self.save_post_data(theme_id,posts)
  	if posts.length > 0 
  		posts.each do |post|
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
  		end
  	end
  end
end