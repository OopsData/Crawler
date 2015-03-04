module ApplicationHelper
	def current?(con)
		return 'active' if con == controller_name
		return nil
	end

	def current_tab?(con,act)
		return 'active' if con == controller_name && act == action_name
	end

	def current_sub_tab?(con,act,para)
		return 'active' if con == controller_name && act == action_name && para == params[:type]
	end

end
