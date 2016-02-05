require 'capybara'
require 'capybara/poltergeist'

class Analyzer
  include Capybara::DSL
  include ActiveSupport::Configurable

  attr_reader :url, :technologies, :content, :to_hash, :keywords, :whois
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
    # Start PhantomJS Session
    @session.visit @url.url

    # Scrape headers and content
    @headers = @session.response_headers
    @content = @session.html.encode('UTF-8', invalid: :replace, undef: :replace)

    # Run analyses
    @metadata = run_metainspector
    @keywords = run_keywords
    @technologies = run_wappalyzer

    # End PhantomJS session
    @session.driver.quit

    # Third-party analyses
    @whois = run_whois
    @logo = run_logo

    # Populate results
    @to_hash = @metadata.merge({
      url: @url.url,
      logo: @logo,
      technologies: @technologies,
      keywords: @keywords,
      whois: @whois
    })
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

    def run_keywords
      @trie_heap = TrieHeap.new(config.many_keywords)
      # use trie heap to find keywords for visible text
      @session.document.text('body').chars.inject("") do |memo, char|
        if char[/[ \r\n\t!"#$%&'()*+,-.:;<=>?@\]\[^_`{|}~\/\\\d]/].nil?
          memo << char.downcase
        elsif !STOP_WORDS.include?(memo) && memo.length > 1
          @trie_heap.add(memo)
          ""
        else
          ""
        end
      end
      @trie_heap.sort
    end

    def whois
      Whois.whois(@url.host).properties
    end

    def run_logo
      logo_url = "http://logo.clearbit.com/#{@url.host}?size=300"
      response = Net::HTTP.get URI(logo_url)
      logo_url unless response == ""
    end
end
