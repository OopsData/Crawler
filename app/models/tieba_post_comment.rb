class TiebaPostComment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :comment_id,type:String
  field :author,type:String  
  field :content,type:String  
  field :date,type:String

  index({ comment_id: 1 }, { background: true } )
  index({ date: 1 }, { background: true } )
  index({tieba_post_id: 1 }, { background: true } )

  belongs_to :tieba_post
  
  def self.save_comment_data(post_id,comments)
  	if comments.length > 0 
  		comments.each do |cmt|
  		  cmomment = TiebaPostComment.where(comment_id:cmt[:cmt_id]).first
  			param    = {tieba_post_id:post_id,comment_id:cmt[:cmt_id],author:cmt[:author],content:cmt[:content],date:cmt[:date]}
  			unless cmomment.present?
  				cmomment = self.create(param)
  			else
  				cmomment.update_attributes(param)
  			end
  		end
  	end
  end
end