class TiebasController < ApplicationController
	protect_from_forgery with: :null_session
	def create
		rack_input = env["rack.input"].read
      	params = Rack::Utils.parse_query(rack_input, "&")		
		Rails.logger.info('=======================================')
		Rails.logger.info(JSON.parse(params).inspect)
		Rails.logger.info('=======================================')
	end
end