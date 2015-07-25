class TiebaPostComment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :comment_id,type:String
  field :author,type:String  
  field :content,type:String  
  field :date,type:String
  belongs_to :tieba_post
  
  def self.save_post_data(post_id,comments)
  	if comments.length > 0 
  		comments.each do |cmt|
  		  cmt   = TiebaPostComment.where(comment_id:cmt['id']).first
  			param = {comment_id:cmt['id'],author:cmt['author'],content:cmt['content'],date:cmt['date']}
  			unless cmt.present?
  				cmt = self.create(param)
  			else
  				cmt.update_attributes(param)
  			end
  		end
  	end
  end
end