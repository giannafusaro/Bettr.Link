require 'capybara'
require 'capybara/poltergeist'

class Analyzer
  include Capybara::DSL
  include ActiveSupport::Configurable

  attr_reader :url, :technologies, :content, :to_hash
  alias :html :content

  def initialize(url)
    # Remove any known trackers
    @url = MetaInspector::URL.new(url)
    @url.untrack!

    # Import App and Category lists
    @maps = JSON.parse File.read(config.apps)
    @apps, @categories = @maps['apps'], @maps['categories']

    # Start PhantomJS and visit URL
    @session = Capybara::Session.new config.driver
    @session.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
  end

  def process!
    @session.visit @url.url
    @headers = @session.response_headers
    @content = @session.html.encode('UTF-8', invalid: :replace, undef: :replace)

    @metadata = run_metainspector
    @technologies = run_wappalyzer
    #keywords = run_keywords
    #whois = run_whois

    @session.driver.quit
    @to_hash = @metadata.merge({ technologies: @technologies, keywords: [] })
  end

  private

    def run_metainspector
      page = MetaInspector::Document.new @url.url, document: @content
      {
        title: page.best_title,
        description: page.description,
        image: page.images.best,
        feed: page.feed,
        meta_tags: page.meta
      }
    end

    def run_wappalyzer
      # Parse header data (keys must be lowercase) and prep driver.data
      headers = @headers.each_with_object({}){ |(k,v),h| h[k.downcase] = v }
      data = { host: @url.host, url: @url.url, headers: headers, html: @content }

      # Pass data to Wappalyzer scripts
      @session.execute_script %Q(
        w.apps = #{@apps.to_json};
        w.categories = #{@categories.to_json};
        w.driver.data = #{data.to_json};)

      # Perform analysis and end session
      JSON.parse @session.evaluate_script "w.driver.init();"
    end
end
