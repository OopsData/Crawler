class TiebasController < ApplicationController
	def create
		Rails.logger.info('=======================================')
		Rails.logger.info(params.inspect)
		Rails.logger.info('=======================================')
	end
end