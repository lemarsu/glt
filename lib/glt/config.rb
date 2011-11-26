require 'yaml'
require 'logger'

class Glt::Config
  class ConfigError < StandardError; end
  attr_reader :conf

  def self.find
    conf_path = [ENV['GLT_CONF_PATH'], "#{Glt::BIN_NAME}.conf", "~/.#{Glt::BIN_NAME}.conf", "/etc/#{Glt::BIN_NAME}.conf"].reject do |path|
      path.to_s.empty?
    end.map {|path| File.expand_path path}.find do |conf_path|
      File.exists?(File.expand_path(conf_path.to_s))
    end


    if conf_path
      new(conf_path)
    else
      raise ConfigError, "Can't find configuration path. aborting"
    end
  end

  def initialize(conf_path)
    @conf = YAML.load_file(conf_path)
    check_log_level
  end

  def logger
    return @logger if @logger
    @logger = Logger.new(log_file)
    @logger.level = Logger.const_get(@log_level)
    @logger
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

  def check_log_level
    log_level = (conf['global']['log_level'] || 'info')
    if Logger::SEV_LABEL.include? log_level.upcase
      @log_level = log_level.upcase
      return
    end
    log_levels = Logger::SEV_LABEL.map(&:downcase) * ', '
    message = %[Unknown log level "#{log_level}", should be one of [#{log_levels}]]
    raise ConfigError, message, caller(2)
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

    def host_name
      URI.parse(url).host
    end

    def rename(str)
      ret = str.dup
      rename_actions.each do |action, *args|
        case action
        when 'sub'
          next unless args.size >= 2
          ret.gsub!(Regexp.new(args[0]), args[1])
        when 'suffix'
          next unless args.size == 1
          ret.gsub!(/$/, args.first)
        when 'prefix'
          next unless args.size == 1
          ret.gsub!(/^/, args.first)
        when 'remove'
          next unless args.size >= 1
          ret.gsub!(Regexp.new(args.first), '')
        end
      end
      # title = str.gsub /[^\w-]+/, '_'
      # "#{title}.torrent"
      ret
    end

    def rename_actions
      (data['rename']||[])
    end

    private :conf
    private :data

  end
end

