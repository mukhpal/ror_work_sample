module Concerns::Api::V1::Docs::IngredientsDoc
  extend ActiveSupport::Concern

  included do
    include Concerns::Api::V1::Docs

    def_param_group :doc_ingredient_list do
      api :GET, '/ingredients', 'Array of all ingredients'
      param_group :headers, desc: 'Header values to be sent'
      param_group :errors, desc: 'Possible errors'
      returns code: 200
    end

    def_param_group :doc_available_measurements do
      api :GET, '/ingredients/available_measurements', 'Array of all available measurment/'
      param_group :headers, desc: 'Header values to be sent'
      param_group :errors, desc: 'Possible errors'
      returns code: 200
    end
  end
end
