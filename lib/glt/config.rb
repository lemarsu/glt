require 'yaml'

class Glt::Config
  attr_reader :conf

  def self.find
    conf_path = [ENV['GLT_CONF_PATH'], "#{Glt::BIN_NAME}.conf", "~/.#{Glt::BIN_NAME}.conf", "/etc/#{Glt::BIN_NAME}.conf"].reject do |path|
      path.to_s.empty?
    end.map {|path| File.expand_path path}.find do |conf_path|
      File.exists?(File.expand_path(conf_path.to_s))
    end

    new(conf_path) if conf_path
  end

  def initialize(conf_path)
    @conf = YAML.load_file(conf_path)
  end

  def logger
    @logger ||= Logger.new(log_file)
  end

  def download_path
    conf['global'] && conf['global']['download_to'] || '.'
  end

  def feeds
    (conf['feeds']||[]).map {|cf| Feed.new self, cf}
  end

  private
  private :conf

  def log_file
    conf['global'] && conf['global']['log_file'] || STDERR
  end

  class Feed
    attr_reader :conf, :data

    def initialize(conf, data)
      @conf, @data = conf, data
    end

    def name
      data["name"]
    end

    def url
      data["url"]
    end

    def exclude
      @exclude ||= data['exclude'] ? Array(data['exclude']) : []
    end

    private :conf
    private :data
  end
end

