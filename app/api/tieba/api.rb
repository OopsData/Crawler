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
        params[:info].each do |data|
          Rails.logger.info data.inspect
          Rails.logger.info '================================'
        end
      end
    end
  end
end