require 'capybara'
require 'capybara/poltergeist'

class Scraper
  include Capybara::DSL
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new app,
      phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],
      js_errors: false,
      debug: false,
      inspector: false
  end

  GLOBALS_SCRIPT = %q(
    (function() {
      var globals = [],
      globalsBlacklist = ['__commandLineAPI','applicationCache','chrome','closed','console','crypto','CSS','defaultstatus',
        'defaultStatus','devicePixelRatio','document','external','frameElement','history','indexedDB','innerHeight',
        'innerWidth','length','localStorage','location','name','offscreenBuffering','opener','outerHeight','outerWidth',
        'pageXOffset','pageYOffset','performance','screen','screenLeft','screenTop','screenX','screenY','scrollX',
        'scrollY','sessionStorage','speechSynthesis','status','styleMedia', 'window'],
      prototype = Object.getPrototypeOf(window);
      for (var prop in window) {
        if (window[prop] != null &&
          !(window[prop]===window) &&
          !(window[prop] instanceof BarProp) &&
          !(window[prop] instanceof Navigator) &&
          !(prop in prototype) &&
          (prop.indexOf('webkit') == -1) &&
          (globalsBlacklist.indexOf(prop)== -1))
        {
          globals.push(prop);
        }
      }
      return globals;
    })();
  ).gsub(/[\n](\s{2,})/,'')

  attr_accessor :url, :session, :document, :headers, :globals, :title, :metas, :text

  # Create a new PhantomJS session in Capybara
  def initialize(url)
    @session = Capybara::Session.new :poltergeist
    @session.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
    get (@url = url)
  end

  # Scrape page data at given URL
  def get(url)
    @session.visit url
    @document = @session.document

    # headers and global JS variables
    @headers = @session.response_headers
    @globals = @session.evaluate_script GLOBALS_SCRIPT

    # metadata and text
    @title = @session.title
    @metas = @session.find_all('meta', visible: false).collect(&:native).collect(&:attributes)
    @text  = @document.text 'body'

    # shut down driver, no need to hang around
    @session.driver.quit

    # return an instance of Scraper
    self
  end

  def to_json
    {
      headers: @headers,
      globals: @globals,
      title: @title,
      metas: @metas,
      text: @text
    }.to_json
  end

  private

    def parse_metadata
    end

    def parse_headers
    end

    def parse_globals
    end

end
