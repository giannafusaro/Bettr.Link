require 'open-uri'
require 'scraper'


class Link < ActiveRecord::Base
  validates :name, :url, presence: true

  def self.parse(url)

    @trie_heap, @content, word = TrieHeap.new, {}, ''

    @page = Scraper.new.get_text(url)
    # @content[:title] = raw.title
    # @content[:selected_elements] = self.html_info(raw)
    # data.search("script").each{ |e| e.unlink }

    # str = Nokogiri.parse(raw, nil, raw.encoding)
    # puts str.inspect
    # puts data.at('body')
    @page.chars.each do |char|
      if char[/[ \r\n\t!"#$%&'()*+,-.:;<=>?@\]\[^_`{|}~\/\\\d]/].nil?
        word << char.downcase
      elsif (!STOP_WORDS.includes?(word) && word.length > 1)
        # puts word
        @trie_heap.add(word)
        word = ''
      else
        word = ''
      end
    end

    @content[:frequent_words] = @trie_heap.heap.sort.inject([]) do |memo, node|
      memo << { "#{node.word}" => node.frequency }
    end and return @content
  end

  def self.html_info(document)
    tags = %([property='og:site_name'],[name='application-name'],
    [name='apple-mobile-web-app-title'], meta[name='description'],
    meta[name='keywords'], [property="og:type"],[name="medium"],
    [name="Classification"],[property="og:video:type"],
    [property="og:audio:type"], [name="category"], [name="topic"],
    [name="twitter:title"], [itemprop="name"], [name="pagename"],
    [name="apple-mobile-web-app-title"], [property="og:title"], document.title
    [property="og:description"], [name="description"], [name="subject"],
    [name="abstract"], [name="subtitle"], [name="keywords"], [rel="fluid-icon"],
    [rel="shortcut icon"], [rel="apple-touch-icon"], [property="og:image"],
    [rel="apple-touch-startup-image"], [name="author"], [name="owner"],
    [name="designer"], [property="fb:admins"], [name="me"], [name="date"],
    [name="url"], [name="identifier-URL"])
    contents = document.search(tags).inject({}) do |memo, n|

      memo[n['property']] = n['content'] unless n['property'].nil?
      # memo[/:(\.*)/.match(n['property']).captures[0]] = n['content'] unless (n['property'].nil? || n['content'].nil?)
      memo
    end and return contents
  end
end
