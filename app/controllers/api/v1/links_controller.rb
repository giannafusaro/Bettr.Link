module Api::V1
  class LinksController < ApiController

    def analyze
      scrape = Scraper.new params[:url]
      render json: scrape.to_json
    end

  end
end
