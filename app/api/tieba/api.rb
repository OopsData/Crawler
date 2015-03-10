module Tieba
  class API < Grape::API
    version 'v1', using: :header, vendor: 'twitter'
    format :json
    prefix :api


    resource :tiebas do
      post :receive_data do
        puts '================================'
        puts params.inspect
        puts '================================'
      end
    end
  end
end