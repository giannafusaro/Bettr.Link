module Api::V1
  class LinksController < ApiController

    def analyze
      render json: { foo: 'bar' }
    end

  end
end
