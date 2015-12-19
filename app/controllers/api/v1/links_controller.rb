module Api::V1
  class LinksController < ApiController

    def analyze
      response = Analyzer.new(params[:url]).process!
      render json: response, status: 200
    rescue
      render json: { error: $!.message, backtrace: $@ }, status: 500
    end

  end
end
