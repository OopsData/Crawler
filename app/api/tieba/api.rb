module Tieba
  class API < Grape::API
    version 'v1', using: :header, vendor: 'tiebas'
    format :json
    prefix :api


    resource :tiebas do
      get  :data do 
        Rails.logger.info 'dddddddddddddddddd'
      end
      post :receive_data do
        #data_arr  = eval(params[:data])
        Rails.logger.info('=========================================')
        Rails.logger.info params.inspect
        Rails.logger.info('=========================================')
        # data_arr.each do |hash|
        #   puts hash[:title]
        #   puts hash[:author]
        #   puts hash[:created]
        #   puts hash[:comment]
        #   Rails.logger.info '----------------------------------------------------------------------------'
        # end
      end
    end
  end
end