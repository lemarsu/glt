require 'open-uri'
require 'cgi'
begin
  require 'simple-rss'
rescue LoadError
  require 'rubygems' and retry
end

class Glt::Feed
  class FeedError < StandardError; end

  def self.open(feed_conf)
    yield new feed_conf
  end

  def initialize(feed_conf)
    @feed_conf = feed_conf
    @feed = open(feed_conf.url) {|f| SimpleRSS.parse f}
    raise FeedError, "Couldn't connect." unless @feed
  rescue Timeout::Error, SystemCallError => ex
    raise FeedError, ex.message, caller(2)
  end

  def items
    all.reject {|i| exclude?(i)}
  end

  def all(&blk)
    @feed.items.map {|i| Item.new(self, i)}.each(&blk)
  end

  def exclude?(item)
    @feed_conf.exclude.map {|re| Regexp.new(re)}.any? {|re| re.match(item.name)}
  end

  class Item
    attr_reader :feed

    def initialize(feed, item)
      @feed, @item = feed, item
    end

    def name
      @item.title
    end

    def url
      CGI.unescapeHTML(@item.link)
    end

    def file_name
      title = name.gsub /[^\w-]+/, '_'
      "#{title}.torrent"
    end

    def excluded?
      feed.exclude?(self)
    end
  end
end

