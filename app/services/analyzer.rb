require 'capybara'
require 'capybara/poltergeist'

class Analyzer
  include Capybara::DSL
  include ActiveSupport::Configurable

  attr_accessor :uri, :technologies

  def initialize(url)
    @uri = URI url

    # Import App and Category lists
    @maps = JSON.parse File.read(config.apps)
    @apps, @categories = @maps['apps'], @maps['categories']

    # Start PhantomJS and visit URL
    @session = Capybara::Session.new config.driver
    @session.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
  end

  def process!
    @session.visit @uri
    @technologies = run_wappalyzer
    @session.driver.quit

    { technologies: @technologies, keywords: [] }
  end

  private

    def run_wappalyzer
      # Parse header and content data (header keys must be lowercase)
      @headers = @session.response_headers.each_with_object({}){ |s,h| h[s[0].downcase] = s[1] }
      @content = @session.html.encode('UTF-8', invalid: :replace, undef: :replace)
      @data = { host: @uri.host, url: @uri.to_s, headers: @headers, html: @content }

      # Pass data to Wappalyzer scripts
      @session.execute_script %Q(
        w.apps = #{@apps.to_json};
        w.categories = #{@categories.to_json};
        w.driver.data = #{@data.to_json};)

      # Perform analysis and end session
      JSON.parse @session.evaluate_script "w.driver.init();"
    end
end
