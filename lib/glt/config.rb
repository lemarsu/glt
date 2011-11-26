class Glt::Config
  attr_reader :conf

  def initialize
    conf_path = [ENV['GLT_CONF_PATH'], "#{BIN_NAME}.conf", "~/.#{BIN_NAME}.conf", "/etc/#{BIN_NAME}.conf"].reject do |path|
      path.to_s.empty?
    end.map {|path| File.expand_path path}.find do |conf_path|
      File.exists?(File.expand_path(conf_path.to_s))
    end

    unless conf_path
      STDERR.puts "Can't find configuration path. aborting"
      exit 2
    end

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

