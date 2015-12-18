require 'open-uri'
require 'scraper'


class Link < ActiveRecord::Base
  validates :name, :url, presence: true
  acts_as_taggable
  
end
