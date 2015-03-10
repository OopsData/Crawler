class TiebasController < ApplicationController
	protect_from_forgery with: :null_session
	def create
		Rails.logger.info('=======================================')
		Rails.logger.info(params.inspect)
		Rails.logger.info('=======================================')
	end
end