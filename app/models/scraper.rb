require 'capybara'
require 'capybara/poltergeist'
class Scraper
  include Capybara::DSL

  GET_GLOBALS_SCRIPT = "(function getGlobals() {
    var globals = [],
    globalsBlacklist = ['__commandLineAPI','applicationCache','chrome','closed','console','crypto','CSS','defaultstatus',
      'defaultStatus','devicePixelRatio','document','external','frameElement','history','indexedDB','innerHeight',
      'innerWidth','length','localStorage','location','name','offscreenBuffering','opener','outerHeight','outerWidth',
      'pageXOffset','pageYOffset','performance','screen','screenLeft','screenTop','screenX','screenY','scrollX',
      'scrollY','sessionStorage','speechSynthesis','status','styleMedia', 'window'];
    var prototype = Object.getPrototypeOf(window);
    for (var prop in window) {
      if ( !(window[prop] instanceof BarProp) && !(window[prop] instanceof Navigator) &&
           (prop.indexOf('webkit') == -1) && (globalsBlacklist.indexOf(prop)== -1) &&
           !(prop in prototype) && !(window[prop]===window) && window[prop] != null ) {
        globals.push(prop);
      }
    }
    return globals;
  }())".gsub(/[\n](\s{2,})/, '')

  attr_accessor :text, :document, :metas, :title, :session, :globals


  # settings for poltergeist driver
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new app,
      js_errors: false,
      phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],
      debug: false,
      inspector: false
  end
  Capybara.default_driver = :poltergeist

  # Create a new PhantomJS session in Capybara
  def initialize
    @session = Capybara::Session.new(:poltergeist)
    @session.driver.headers = { 'User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
  end

  def get(url)
    @session.visit url

    @document = @session.document
    @title = @session.title
    @metas  = @session.find_all('meta', visible: false).collect(&:native).collect(&:attributes)
    @text = @document.text 'body'
    @globals = @session.evaluate_script(GET_GLOBALS_SCRIPT)
    # shut down driver, no need to hang around
    @session.driver.quit
  end


end
