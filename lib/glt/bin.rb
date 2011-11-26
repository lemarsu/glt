class Glt::Bin
  attr_reader :conf

  def initialize(conf)
    @conf = conf
  end

  def start
    logger.info "Starting #{Glt::BIN_NAME}"
    conf.feeds.each {|fc| process_feed(fc)}
    logger.info "Exiting #{Glt::BIN_NAME}"
  end

  private :conf
  private

  def downloader
    @downloader ||= Glt::Downloader.new(conf.download_path)
  end

  def process_feed(feed_conf)
    logger.info "Searching #{feed_conf.name}..."

    Glt::Feed.open feed_conf do |feed|
      feed.all.each {|fi| download_feed_item(fi)}
    end
  ensure
    logger.info "Finished #{feed_conf.name}"
  end

  def download_feed_item(fi)
    if fi.excluded?
      logger.info %[Skipping file "#{fi.file_name}: Excluded by pattern."]
      return
    end

    downloader.download_to(fi.url, fi.file_name)
  rescue Glt::Downloader::DownloadError => x
    logger.warn %[Couldn't download "#{fi.url}" into "#{fi.file_name}": #{x}]
  else
    logger.info %[Downloaded "#{fi.url}" into "#{fi.file_name}"]
  end

  def logger
    conf.logger
  end
end
