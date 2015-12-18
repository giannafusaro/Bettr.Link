Analyzer.configure do |config|

  WAPPALYZER_PATH = "#{Rails.root}/vendor/wappalyzer"

  config.many_keywords = 15

  config.driver = :poltergeist_with_wappalyzer
  config.apps = "#{WAPPALYZER_PATH}/apps.json"

  # Register PhantomJS driver (Poltergeist)
  Capybara.register_driver :poltergeist_with_wappalyzer do |app|
    Capybara::Poltergeist::Driver.new app,
      phantomjs: '/usr/local/bin/phantomjs',
      phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],
      extensions: ["#{WAPPALYZER_PATH}/wappalyzer.js", "#{WAPPALYZER_PATH}/driver.js"],
      js_errors: false,
      inspector: false,
      debug: (Rails.env != 'production')
  end

end
