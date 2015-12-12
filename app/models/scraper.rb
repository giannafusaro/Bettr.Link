require 'capybara'
require 'capybara/poltergeist'
class Scraper
  include Capybara::DSL
  Capybara.default_driver = :poltergeist
  # Create a new PhantomJS session in Capybara
  def initialize
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, js_errors: false)
    end

    # Start up a new thread
    @session = Capybara::Session.new(:poltergeist)
    @session.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
  end

  def get_text(url)
    start = Time.now
    @session.visit url
    body = @session.document.text 'body'
    ap "#{Time.now-start} to finish"
    body
  end

end
