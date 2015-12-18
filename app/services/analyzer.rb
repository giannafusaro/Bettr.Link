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
    @session.visit @url.url
    @headers = @session.response_headers
    @content = @session.html.encode('UTF-8', invalid: :replace, undef: :replace)

    @metadata = run_metainspector
    @technologies = run_wappalyzer
    @keywords = run_keywords

    @whois = Whois.whois(@url.host).properties

    @session.driver.quit
    @to_hash = @metadata.merge({ technologies: @technologies, keywords: @keywords, whois: @whois })
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
        elsif !STOP_WORDS.includes?(memo) && memo.length > 1
          @trie_heap.add(memo)
          ""
        else
          ""
        end
      end
      @trie_heap.sort
    end
end
